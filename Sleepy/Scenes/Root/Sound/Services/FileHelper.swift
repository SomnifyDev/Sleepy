// Copyright (c) 2021 Sleepy.

import Foundation

class FileHelper
{
    class func sizeForLocalFilePath(filePath: String) -> UInt64
    {
        do
        {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]
            {
                return (fileSize as! NSNumber).uint64Value
            }
            else
            {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        }
        catch
        {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }

    class func creationDateForLocalFilePath(filePath: String) -> Date?
    {
        do
        {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            return fileAttributes[FileAttributeKey.creationDate] as? Date
        }
        catch
        {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return nil
    }

    class func creationDateForLocalFilePath(for file: URL) -> Date
    {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
           let creationDate = attributes[FileAttributeKey.creationDate] as? Date
        {
            return creationDate
        }
        else
        {
            return Date()
        }
    }

    class func covertToFileString(with size: UInt64) -> String
    {
        var convertedValue = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        while convertedValue > 1024
        {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}
