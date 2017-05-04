//
//  NetworkHelpers.swift
//  GroupProject
//
//  Created by Nana on 5/4/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

/// Used to represent whether a request was successful or encountered an error.
enum Result<Value>: CustomDebugStringConvertible {
    case success(Value)
    case failure(APIError)

    /// Returns `true` if the result is a success, `false` otherwise.
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the associated value if the result is a success, `nil` otherwise.
    var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var error: APIError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }

    /// The debug textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure in addition to the value or error.
    var debugDescription: String {
        switch self {
        case .success(let value):
            return "SUCCESS: \(value)"
        case .failure(let error):
            return "FAILURE: \(error.localizedDescription)"
        }
    }
}

// Used to represent the general cases of network errors
enum APIError: Error {
    case InvalidData
    case DataUnavailable
    case RemoteError(String?)
    
    var localizedDescription: String {
        switch self {
        case .InvalidData:
            return "Invalid data"
        case .DataUnavailable:
            return "Data not available"
        case .RemoteError(let reason):
            return reason ?? "Unknown error"
        }
    }
}
