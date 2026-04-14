import { Injectable } from '@nestjs/common';
import { Observable, Subject, filter, map } from 'rxjs';

export type StreamEvent = {
  channel: string;
  event: string;
  payload: unknown;
  userId?: string;
};

@Injectable()
export class EventsService {
  private readonly bus = new Subject<StreamEvent>();

  emit(event: StreamEvent) {
    this.bus.next(event);
  }

  streamPublic(channels?: string[]): Observable<MessageEvent> {
    return this.bus.pipe(
      filter((item) => !item.userId),
      filter(
        (item) =>
          !channels || channels.length === 0 || channels.includes(item.channel),
      ),
      map(
        (item) =>
          ({
            type: item.event,
            data: item,
          }) as MessageEvent,
      ),
    );
  }

  streamUser(userId: string, channels?: string[]): Observable<MessageEvent> {
    return this.bus.pipe(
      filter((item) => !item.userId || item.userId === userId),
      filter(
        (item) =>
          !channels || channels.length === 0 || channels.includes(item.channel),
      ),
      map(
        (item) =>
          ({
            type: item.event,
            data: item,
          }) as MessageEvent,
      ),
    );
  }
}
