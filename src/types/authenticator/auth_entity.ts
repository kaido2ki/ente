export interface AuthEntity {
    id: string;
    encryptedData: string | null;
    header: string | null;
    isDeleted: boolean;
    createdAt: number;
    updatedAt: number;
}
