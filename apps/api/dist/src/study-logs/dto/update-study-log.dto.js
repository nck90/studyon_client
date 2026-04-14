"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateStudyLogDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_study_log_dto_1 = require("./create-study-log.dto");
class UpdateStudyLogDto extends (0, swagger_1.PartialType)(create_study_log_dto_1.CreateStudyLogDto) {
}
exports.UpdateStudyLogDto = UpdateStudyLogDto;
//# sourceMappingURL=update-study-log.dto.js.map