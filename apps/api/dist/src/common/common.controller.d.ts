export declare class CommonController {
    getSubjects(): {
        success: boolean;
        data: string[];
        meta: {};
    };
    getCodes(type?: string): {
        success: boolean;
        data: Record<string, string[]>;
        meta: {};
    };
}
