/**
 * @file debug.h
 * @author your name (you@domain.com)
 * @brief
 * @version 0.1
 * @date 2023-07-15
 *
 * @copyright Copyright (c) 2023
 *
 */

/**
 * @brief The level that we should show debug events at.
 *
 */
#pragma once
typedef enum LogLevel
{
    Log_LDefault = 0,
    Log_LDebug = 1,
    Log_LInfo = 2,
    Log_LWarn = 3,
    Log_LError = 4,
} LogLevel;
/**
 * @brief Opens and/or creates a file for debug logging.
 *
 * @return 1 if successful, 0 if failed.
 */
int InitializeDebugLogFile();
/**
 * @brief Closes the open file for logging.
 *
 * @return
 */
int CloseDebugLogFile();
/**
 * @brief Log a Debug log in a printf format
 *
 * @param format The printf styped text
 * @param ... The variables for the printf
 */
void LogDebug(const char *format, ...);
/**
 * @brief Log a warning log in a printf format
 *
 * @param format The printf styped text
 * @param ... The variables for the printf
 */
void LogInfo(const char *format, ...);
/**
 * @brief Log a warning log in a printf format
 *
 * @param format The printf styped text
 * @param ... The variables for the printf
 */
void LogWarn(const char *format, ...);
/**
 * @brief Log a error log in a printf format
 *
 * @param format The printf styped text
 * @param ... The variables for the printf
 */
void LogError(const char *format, ...);

void SetLogLevel(int newLevel);