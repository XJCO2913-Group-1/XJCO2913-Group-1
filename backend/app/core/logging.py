import logging
import sys
from typing import List

from loguru import logger
from pydantic import BaseModel


class InterceptHandler(logging.Handler):
    """
    Default handler from examples in loguru documentation.
    See https://loguru.readthedocs.io/en/stable/overview.html#entirely-compatible-with-standard-logging
    """

    def emit(self, record):
        # Get corresponding Loguru level if it exists
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        # Find caller from where originated the logged message
        frame, depth = logging.currentframe(), 2
        while frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(
            level, record.getMessage()
        )


class LoggingSettings(BaseModel):
    LOGGING_LEVEL: str = logging.INFO
    LOGGERS: List[str] = ["uvicorn", "uvicorn.access", "uvicorn.error", "fastapi"]


logging_settings = LoggingSettings()


def setup_app_logging(config: LoggingSettings) -> None:
    """
    Initialize loguru logger for FastAPI application.
    """
    # Intercept everything at the root logger
    logging.root.handlers = [InterceptHandler()]
    logging.root.setLevel(config.LOGGING_LEVEL)

    # Remove every other logger's handlers and propagate to root logger
    for name in logging.root.manager.loggerDict.keys():
        logging.getLogger(name).handlers = []
        logging.getLogger(name).propagate = True

    # Configure loguru
    logger.configure(
        handlers=[
            {
                "sink": sys.stdout,
                "level": config.LOGGING_LEVEL,
                "format": "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
            }
        ]
    )
