import { Observable } from 'rxjs';
export type StreamEvent = {
    channel: string;
    event: string;
    payload: unknown;
    userId?: string;
};
export declare class EventsService {
    private readonly bus;
    emit(event: StreamEvent): void;
    streamPublic(channels?: string[]): Observable<MessageEvent>;
    streamUser(userId: string, channels?: string[]): Observable<MessageEvent>;
}
