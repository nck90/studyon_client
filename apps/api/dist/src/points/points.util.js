"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.STUDY_TIME_POINTS_PER_HOUR = void 0;
exports.calculateStudyTimePoints = calculateStudyTimePoints;
exports.STUDY_TIME_POINTS_PER_HOUR = 100;
function calculateStudyTimePoints(studySeconds) {
    if (studySeconds <= 0) {
        return 0;
    }
    return Math.floor((studySeconds * exports.STUDY_TIME_POINTS_PER_HOUR) / 3600);
}
//# sourceMappingURL=points.util.js.map