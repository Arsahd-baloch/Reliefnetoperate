export declare class CloudinaryService {
    uploadImage(fileBuffer: Buffer, folder?: string): Promise<string>;
    private _saveLocally;
    private _uploadToCloudinary;
    deleteImage(publicId: string): Promise<void>;
}
export declare const cloudinaryService: CloudinaryService;
//# sourceMappingURL=cloudinary.service.d.ts.map