import { CreateGoodsCampaignInput, UpdateGoodsCampaignInput } from './goodsCampaigns.schema.js';
export declare class GoodsCampaignsService {
    getActive(): Promise<any[]>;
    getById(id: number): Promise<any>;
    getMine(ngoId: number): Promise<any[]>;
    create(input: CreateGoodsCampaignInput, ngoId: number): Promise<any>;
    update(id: number, input: UpdateGoodsCampaignInput, ngoId: number): Promise<any>;
    delete(id: number, ngoId: number): Promise<void>;
}
export declare const goodsCampaignsService: GoodsCampaignsService;
//# sourceMappingURL=goodsCampaigns.service.d.ts.map