//
//  NetworkError.swift
//  PKBPartyKit
//
//  Created by alfian0 on 2/6/18.
//  Copyright © 2018 Extra Integer. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    /// Unknown or not supported error.
    case Unknown
    
    /// Not connected to the internet.
    case NotConnectedToInternet
    
    /// International data roaming turned off.
    case InternationalRoamingOff
    
    /// Cannot reach the server.
    case NotReachedServer
    
    /// Connection is lost.
    case ConnectionLost
    
    /// Incorrect data returned from the server.
    case IncorrectDataReturned
    
    /// Connection is insecure
    case InsecureConnection
    
    case Cancelled
    
    case SoftError(message: String?)
    
    public var message: String {
        switch self {
        case .IncorrectDataReturned:
            return "Incorrect JSON format"
        case .SoftError(let message):
            return message ?? "Something when wrong"
        case .NotConnectedToInternet:
            return "You are offline"
        case .NotReachedServer:
            return "Server not found"
        case .ConnectionLost:
            return "Connection lost"
        case .InsecureConnection:
            return "Insecure connection"
        case .Cancelled:
            return "Request Cancelled"
        default:
            return "Unknown error"
        }
    }
    
    //    var type: Notification.MessageType {
    //        switch self {
    //        case .NotConnectedToInternet:
    //            return .warning
    //        default:
    //            return .error
    //        }
    //    }
    
    internal init(error: NSError) {
        switch error.domain {
        case NSURLErrorDomain:
            switch error.code {
            case NSURLErrorUnknown:
                self = .Unknown
            case NSURLErrorCancelled:
                self = .Cancelled
            case NSURLErrorBadURL:
                self = .IncorrectDataReturned
            case NSURLErrorTimedOut:
                self = .NotReachedServer
            case NSURLErrorUnsupportedURL:
                self = .IncorrectDataReturned
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                self = .NotReachedServer
            case NSURLErrorDataLengthExceedsMaximum:
                self = .IncorrectDataReturned
            case NSURLErrorNetworkConnectionLost:
                self = .ConnectionLost
            case NSURLErrorDNSLookupFailed:
                self = .NotReachedServer
            case NSURLErrorHTTPTooManyRedirects:
                self = .Unknown
            case NSURLErrorResourceUnavailable:
                self = .IncorrectDataReturned
            case NSURLErrorNotConnectedToInternet:
                self = .NotConnectedToInternet
            case NSURLErrorRedirectToNonExistentLocation, NSURLErrorBadServerResponse:
                self = .IncorrectDataReturned
            case NSURLErrorUserCancelledAuthentication, NSURLErrorUserAuthenticationRequired:
                self = .Unknown
            case NSURLErrorZeroByteResource, NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData:
                self = .IncorrectDataReturned
            case NSURLErrorCannotParseResponse:
                self = .IncorrectDataReturned
            case NSURLErrorInternationalRoamingOff:
                self = .InternationalRoamingOff
            case NSURLErrorCallIsActive, NSURLErrorDataNotAllowed, NSURLErrorRequestBodyStreamExhausted:
                self = .Unknown
            case NSURLErrorFileDoesNotExist, NSURLErrorFileIsDirectory:
                self = .IncorrectDataReturned
            case
            NSURLErrorNoPermissionsToReadFile,
            NSURLErrorSecureConnectionFailed,
            NSURLErrorServerCertificateHasBadDate,
            NSURLErrorServerCertificateUntrusted,
            NSURLErrorServerCertificateHasUnknownRoot,
            NSURLErrorServerCertificateNotYetValid,
            NSURLErrorClientCertificateRejected,
            NSURLErrorClientCertificateRequired,
            NSURLErrorCannotLoadFromNetwork,
            NSURLErrorCannotCreateFile,
            NSURLErrorCannotOpenFile,
            NSURLErrorCannotCloseFile,
            NSURLErrorCannotWriteToFile,
            NSURLErrorCannotRemoveFile,
            NSURLErrorCannotMoveFile,
            NSURLErrorDownloadDecodingFailedMidStream,
            NSURLErrorDownloadDecodingFailedToComplete:
                self = .Unknown
            default:
                self = .Unknown
            }
        case String(kCFErrorDomainCFNetwork):
            switch error.code {
            case
            Int(CFNetworkErrors.cfurlErrorServerCertificateNotYetValid.rawValue),
            Int(CFNetworkErrors.cfurlErrorServerCertificateUntrusted.rawValue),
            Int(CFNetworkErrors.cfurlErrorServerCertificateHasBadDate.rawValue),
            Int(CFNetworkErrors.cfurlErrorServerCertificateHasUnknownRoot.rawValue),
            Int(CFNetworkErrors.cfurlErrorClientCertificateRejected.rawValue),
            Int(CFNetworkErrors.cfurlErrorClientCertificateRequired.rawValue),
            Int(CFNetworkErrors.cfErrorHTTPSProxyConnectionFailure.rawValue),
            Int(CFNetworkErrors.cfurlErrorSecureConnectionFailed.rawValue),
            Int(CFNetworkErrors.cfurlErrorCannotLoadFromNetwork.rawValue),
            Int(CFNetworkErrors.cfurlErrorCancelled.rawValue):
                self = .InsecureConnection
            case Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue):
                self = .NotConnectedToInternet
            default:
                self = .Unknown
            }
        default:
            self = .Unknown
        }
    }
}
