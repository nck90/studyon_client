import { JwtPayload } from "../auth/types/jwt-payload.type";
import { EventsService } from './events.service';
export declare class EventsController {
    private readonly eventsService;
    constructor(eventsService: EventsService);
    streamPublic(channels?: string): import("rxjs").Observable<MessageEvent<any>>;
    streamMe(user: JwtPayload, channels?: string): import("rxjs").Observable<MessageEvent<any>>;
}
