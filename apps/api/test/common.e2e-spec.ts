import { INestApplication, VersioningType } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request, { Response } from 'supertest';
import { CommonController } from '../src/common/common.controller';

type SubjectsResponse = {
  success: boolean;
  data: string[];
};

describe('Common endpoints (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [CommonController],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /api/v1/common/subjects', async () => {
    const httpServer = app.getHttpServer() as Parameters<typeof request>[0];

    await request(httpServer)
      .get('/api/v1/common/subjects')
      .expect(200)
      .expect((response: Response) => {
        const body = response.body as SubjectsResponse;
        expect(body.success).toBe(true);
        expect(Array.isArray(body.data)).toBe(true);
      });
  });
});
