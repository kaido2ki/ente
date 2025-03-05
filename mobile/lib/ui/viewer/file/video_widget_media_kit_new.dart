import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:media_kit/media_kit.dart";
import "package:media_kit_video/media_kit_video.dart";
import "package:photos/core/constants.dart";
import "package:photos/core/event_bus.dart";
import "package:photos/events/guest_view_event.dart";
import "package:photos/events/pause_video_event.dart";
import "package:photos/events/stream_switched_event.dart";
import "package:photos/generated/l10n.dart";
import "package:photos/models/file/extensions/file_props.dart";
import "package:photos/models/file/file.dart";
import "package:photos/service_locator.dart";
import "package:photos/services/files_service.dart";
import "package:photos/theme/colors.dart";
import "package:photos/ui/actions/file/file_actions.dart";
import "package:photos/ui/common/loading_widget.dart";
import "package:photos/ui/viewer/file/video_widget_media_kit_common.dart"
    as common;
import "package:photos/utils/dialog_util.dart";
import "package:photos/utils/file_util.dart";
import "package:photos/utils/toast_util.dart";

class VideoWidgetMediaKitNew extends StatefulWidget {
  final EnteFile file;
  final String? tagPrefix;
  final Function(bool)? playbackCallback;
  final bool isFromMemories;
  final void Function() onStreamChange;
  final File? preview;
  final bool selectedPreview;

  const VideoWidgetMediaKitNew(
    this.file, {
    this.tagPrefix,
    this.playbackCallback,
    this.isFromMemories = false,
    required this.onStreamChange,
    this.preview,
    required this.selectedPreview,
    super.key,
  });

  @override
  State<VideoWidgetMediaKitNew> createState() => _VideoWidgetMediaKitNewState();
}

class _VideoWidgetMediaKitNewState extends State<VideoWidgetMediaKitNew>
    with WidgetsBindingObserver {
  final Logger _logger = Logger("VideoWidgetMediaKitNew");
  late final player = Player();
  VideoController? controller;
  final _progressNotifier = ValueNotifier<double?>(null);
  bool _isAppInFG = true;
  late StreamSubscription<PauseVideoEvent> pauseVideoSubscription;
  bool isGuestView = false;
  late final StreamSubscription<GuestViewEvent> _guestViewEventSubscription;
  bool _isGuestView = false;
  StreamSubscription<StreamSwitchedEvent>? _streamSwitchedSubscription;

  @override
  void initState() {
    _logger.info(
      'initState for ${widget.file.generatedID} with tag ${widget.file.tag} and name ${widget.file.displayName}',
    );
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.selectedPreview) {
      loadPreview();
    } else {
      loadOriginal();
    }

    pauseVideoSubscription = Bus.instance.on<PauseVideoEvent>().listen((event) {
      player.pause();
    });
    _guestViewEventSubscription =
        Bus.instance.on<GuestViewEvent>().listen((event) {
      setState(() {
        _isGuestView = event.isGuestView;
      });
    });
    _streamSwitchedSubscription =
        Bus.instance.on<StreamSwitchedEvent>().listen((event) {
      if (event.type != PlayerType.mediaKit || !mounted) return;
      if (event.selectedPreview) {
        loadPreview();
      } else {
        loadOriginal();
      }
    });
  }

  void loadPreview() {
    _setVideoController(widget.preview!.path);
  }

  void loadOriginal() {
    if (widget.file.isRemoteFile) {
      _loadNetworkVideo();
      _setFileSizeIfNull();
    } else if (widget.file.isSharedMediaToAppSandbox) {
      final localFile = File(getSharedMediaFilePath(widget.file));
      if (localFile.existsSync()) {
        _setVideoController(localFile.path);
      } else if (widget.file.uploadedFileID != null) {
        _loadNetworkVideo();
      }
    } else {
      widget.file.getAsset.then((asset) async {
        if (asset == null || !(await asset.exists)) {
          if (widget.file.uploadedFileID != null) {
            _loadNetworkVideo();
          }
        } else {
          // ignore: unawaited_futures
          asset.getMediaUrl().then((url) {
            _setVideoController(
              url ??
                  'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4',
            );
          });
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInFG = true;
    } else {
      _isAppInFG = false;
    }
  }

  @override
  void dispose() {
    _streamSwitchedSubscription?.cancel();
    _guestViewEventSubscription.cancel();
    pauseVideoSubscription.cancel();
    removeCallBack(widget.file);
    _progressNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _isGuestView
          ? null
          : (d) => {
                if (d.delta.dy > dragSensitivity)
                  {
                    Navigator.of(context).pop(),
                  }
                else if (d.delta.dy < (dragSensitivity * -1))
                  {
                    showDetailsSheet(context, widget.file),
                  },
              },
      child: Center(
        child: controller != null
            ? common.VideoWidget(
                widget.file,
                controller!,
                widget.playbackCallback,
                isFromMemories: widget.isFromMemories,
                onStreamChange: widget.onStreamChange,
                isPreviewPlayer: widget.selectedPreview,
              )
            : const Center(
                child: EnteLoadingWidget(
                  size: 32,
                  color: fillBaseDark,
                  padding: 0,
                ),
              ),
      ),
    );
  }

  void _loadNetworkVideo() {
    getFileFromServer(
      widget.file,
      progressCallback: (count, total) {
        if (!mounted) {
          return;
        }
        _progressNotifier.value = count / (widget.file.fileSize ?? total);
        if (_progressNotifier.value == 1) {
          if (mounted) {
            showShortToast(context, S.of(context).decryptingVideo);
          }
        }
      },
    ).then((file) {
      if (file != null) {
        _setVideoController(file.path);
      }
    }).onError((error, stackTrace) {
      showErrorDialog(
        context,
        S.of(context).error,
        S.of(context).failedToDownloadVideo,
      );
    });
  }

  void _setFileSizeIfNull() {
    if (widget.file.fileSize == null && widget.file.canEditMetaInfo) {
      FilesService.instance
          .getFileSize(widget.file.uploadedFileID!)
          .then((value) {
        widget.file.fileSize = value;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _setVideoController(String url) {
    if (mounted) {
      setState(() {
        if (controller == null) {
          player.setPlaylistMode(
            localSettings.shouldLoopVideo()
                ? PlaylistMode.single
                : PlaylistMode.none,
          );
          controller = VideoController(player);
        }
        player.open(Media(url), play: _isAppInFG);
      });
    }
  }
}
