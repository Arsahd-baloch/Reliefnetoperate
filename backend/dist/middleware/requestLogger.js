import { v4 as uuidv4 } from 'uuid';
import { logger } from '../common/logger.js';
export const requestLogger = (req, res, next) => {
    const requestId = uuidv4();
    req.id = requestId;
    res.setHeader('X-Request-Id', requestId);
    const start = Date.now();
    const { method, url } = req;
    const userId = req.user?.id;
    logger.info(`Incoming ${method} ${url}`, {
        requestId,
        method,
        url,
        userId,
    });
    res.on('finish', () => {
        const duration = Date.now() - start;
        const { statusCode } = res;
        logger.info(`Completed ${method} ${url} ${statusCode} in ${duration}ms`, {
            requestId,
            method,
            url,
            statusCode,
            duration,
            userId: req.user?.id,
        });
    });
    next();
};
//# sourceMappingURL=requestLogger.js.map