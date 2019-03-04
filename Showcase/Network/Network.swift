//
//  NetworkService.swift
//  Showcase
//
//  Created by Vaishnavi on 12/2/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

import Foundation

public class Network: NSObject, URLSessionDelegate {
    
    var errorMessage = ""
    typealias DataTaskCompletionHandler = (Data, String) -> Void
    
    let defaultSession = URLSession(configuration: .default)
    
    var dataTask: URLSessionDataTask?
 
    func genericDataTask(url: URL, completion: @escaping DataTaskCompletionHandler) {
        dataTask?.cancel()
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            defer { self.dataTask = nil }
            
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                DispatchQueue.main.async {
                    completion(data, self.errorMessage)
                }
            }
        }
        dataTask?.resume()
    }
}



/*
import Foundation
import Result
// MARK: QantasNetworkService

/// Network Service used to handle requests.
public class QantasNetworkService: NSObject, URLSessionDelegate {
    
    // MARK: Keys
    
    public enum Authorization {
        case basic(clientSecret: String)
        case bearer(accessToken: String)
        
        var header: String {
            switch self {
            case .basic(clientSecret: let clientSecret):
                return "Basic \(clientSecret)"
            case .bearer(accessToken: let accessToken):
                return "Bearer \(accessToken)"
            }
        }
    }
    
    public struct Keys {
        static let authorization = "Authorization"
        static let errorDomain = "QantasNetworking"
        public static let errorResponseBody = "errorResponseBody"
        public static let errorResponseJSON = "errorResponseJSON"
    }
    
    // MARK: Completion Handlers
    
    /// Data task completion handler.
    public typealias DataTaskCompletionHandler = (Result<(URLResponse, Data), NSError>) -> Void
    
    /// JSON task completion handler.
    public typealias DataTaskJSONCompletionHandler = (Result<(URLResponse, JSON), NSError>) -> Void
    
    /// Download task completion handler.
    public typealias DownloadTaskCompletionHandler = (Result<(URLResponse, URL), NSError>) -> Void
    
    public private(set) var session: URLSession!
    
    // MARK: Network Service
    
    public init(configuration: URLSessionConfiguration = .default) {
        super.init()
        session = makeSession(configuration: configuration)
    }
    
    /// Designated initializer.
    private override init() {
        super.init()
    }
    
    /// HTTP Request timeout. Set before creating QantasNetworkService
    public static var requestTimeout: TimeInterval = 60
    
    /// HTTP Resource timeout. Set before creating QantasNetworkService
    public static var resourceTimeout: TimeInterval = 60
    
    deinit {
        finishTasksAndInvalidate()
    }
    
    /// The default URLSession for handling network requests.
    private func makeSession(configuration: URLSessionConfiguration) -> URLSession {
        configuration.timeoutIntervalForRequest = QantasNetworkService.requestTimeout
        configuration.timeoutIntervalForResource = QantasNetworkService.resourceTimeout
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }
    
    // MARK: Generic HTTP Requests
    
    /// Generic asynchronous network request that will be started immediately. Fully customizable with an `URLRequest`.
    ///
    /// - Parameters:
    ///   - request: An `URLRequest` object.
    ///   - completion: Upon success, returns the `Data` and `URLHTTPResponse`. Failure will return an `NSError`.
    /// - Returns: The corresponding `URLSessionDataTask` created by `URLSession` that will handle the request. This may be used to cancel the request.
    @discardableResult public func genericDataTask(withRequest request: URLRequest,
                                                   authorization: Authorization? = nil,
                                                   completion: @escaping DataTaskCompletionHandler) -> URLSessionDataTask {
        var mutableRequest = request
        
        if let authorization = authorization {
            mutableRequest.addValue(authorization.header, forHTTPHeaderField: Keys.authorization)
        }
        
        let task = session.dataTask(with: mutableRequest) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    completion(.failure(error))
                } else {
                    if let data = data, let response = response, let httpResponse = response as? HTTPURLResponse {
                        if (httpResponse.statusCode >= 200) && (httpResponse.statusCode < 300) {
                            completion(.success((response, data)))
                        } else {
                            var userInfo: [String: Any] = [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), Keys.errorResponseBody: data]
                            
                            if let errorJSON = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as? JSON {
                                userInfo[Keys.errorResponseJSON] = errorJSON
                            }
                            
                            let serverError = NSError(domain: Keys.errorDomain, code: httpResponse.statusCode, userInfo: userInfo)
                            completion(.failure(serverError))
                        }
                    } else {
                        completion(.failure(NetworkError.unknown))
                    }
                }
            }
            self?.postCompleteTaskNotification(response: response, dataBody: data)
        }
        self.postStartTaskNotification(request: mutableRequest)
        task.resume()
        return task
    }
    
    /// Generic synchronous network request that will be started immediately. Fully customizable with an `URLRequest`. Returns `JSON` instead of `Data`.
    ///
    /// - Parameters:
    ///   - request: An `URLRequest` object.
    ///   - completion: Upon success, returns `JSON` and `URLHTTPResponse`. Failure will return an `NSError`.
    /// - Returns: The corresponding `URLSessionDataTask` created by `URLSession` that will handle the request. This may be used to cancel the request.
    @discardableResult public func genericJSONDataTask(withRequest request: URLRequest,
                                                       authorization: Authorization? = nil,
                                                       completion: @escaping DataTaskJSONCompletionHandler) -> URLSessionDataTask {
        let task = genericDataTask(withRequest: request, authorization: authorization) { result in
            switch result {
            case .success(let (response, data)):
                // If data is empty, but status is success. We pass through empty data (or else the serialization would fail).
                if data.isEmpty,
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 204 {
                    completion(.success((response, JSON())))
                    return
                }
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? JSON else {
                        completion(.failure(NetworkError.jsonConversion))
                        return
                    }
                    completion(.success((response, json)))
                } catch (let error) {
                    completion(.failure(error as NSError))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
    
    /// Generic asynchronous network download request that will be started immediately. Fully customizable with an `URLRequest`.
    ///
    /// - Parameters:
    ///   - request: A `URLRequest` object.
    ///   - completion: Upon success, returns a filepath `URL` and `URLHTTPResponse`. Failure will return an NSError.
    /// - Returns: The corresponding `URLSessionDownloadTask` created by `URLSession` that will handle the request. This may be used to cancel the request.
    @discardableResult public func genericDownloadTask(withRequest request: URLRequest,
                                                       authorization: Authorization? = nil,
                                                       completion: @escaping DownloadTaskCompletionHandler) -> URLSessionDownloadTask {
        var mutableRequest = request
        
        if let authorization = authorization {
            mutableRequest.addValue(authorization.header, forHTTPHeaderField: Keys.authorization)
        }
        
        let task = session.downloadTask(with: mutableRequest) { [weak self] (url: URL?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    completion(.failure(error))
                } else {
                    guard let url = url, let response = response else {
                        completion(.failure(NetworkError.unknown))
                        return
                    }
                    completion(.success((response, url)))
                }
            }
            self?.postCompleteTaskNotification(response: response, dataBody: nil)
        }
        
        self.postStartTaskNotification(request: mutableRequest)
        task.resume()
        return task
    }
    
    // MARK: Convenience HTTP REST Data Methods
    
    /// Asynchronous network request that will be started immediately using a request type (`.get` or `.post`)
    ///
    /// - Parameters:
    ///   - requestType: The `HTTPRequestType` object. E.g. `.get` or `.post(JSON)`.
    ///   - headers: Any extra HTTP headers.
    ///   - url: The request URL.
    ///   - completion:  Upon success, returns the `Data` and `URLHTTPResponse`. Failure will return an `NSError`.
    /// - Returns: The corresponding `URLSessionDataTask` created by `URLSession` that will handle the request. This may be used to cancel the request.
    @discardableResult public func performDataTask(requestType: HTTPRequestType,
                                                   authorization: Authorization? = nil,
                                                   additionalHeaders headers: HTTPHeaders?,
                                                   url: URL,
                                                   completion: @escaping DataTaskCompletionHandler) -> URLSessionDataTask? {
        guard var request = requestType.request else {
            completion(.failure(NetworkError.dataConversion))
            return nil
        }
        
        request.url = url
        request.addHeaders(headers: headers)
        
        return genericDataTask(withRequest: request, authorization: authorization, completion: completion)
    }
    
    /// Asynchronous network request that will be started immediately using a request type (`.get` or `.post`)
    ///
    /// - Parameters:
    ///   - requestType: The `HTTPRequestType` object. E.g. `.get` or `.post(JSON)`.
    ///   - headers: Any extra HTTP headers.
    ///   - url: The request URL.
    ///   - completion:  Upon success, returns `JSON` and `URLHTTPResponse`. Failure will return an `NSError`.
    /// - Returns: The corresponding URLSessionDataTask created by URLSession that will handle the request. This may be used to cancel the request.
    @discardableResult public func performJSONDataTask(requestType: HTTPRequestType,
                                                       authorization: Authorization? = nil,
                                                       additionalHeaders headers: HTTPHeaders?,
                                                       url: URL,
                                                       completion: @escaping DataTaskJSONCompletionHandler) -> URLSessionDataTask? {
        guard var request = requestType.request else {
            completion(.failure(NetworkError.dataConversion))
            return nil
        }
        
        request.url = url
        request.addHeaders(headers: headers)
        
        return genericJSONDataTask(withRequest: request, authorization: authorization, completion: completion)
    }
    
    // MARK: Downloading Data
    
    /// Asynchronous network request to download data with a URL.
    ///
    /// - Parameters:
    ///   - url: `URL` to the data.
    ///   - progressHandler: An optional progress handler that will get called with the progress completed so far.
    ///   - completion: Upon success, returns a filepath `URL` and `URLHTTPResponse`. Failure will return an `NSError`.
    /// - Returns: The corresponding `URLSessionDownloadTask` created by `URLSession` that will handle the request. This may be used to cancel the request.
    @discardableResult public func downloadData(withURL url: URL,
                                                authorization: Authorization? = nil,
                                                completion: @escaping DownloadTaskCompletionHandler) -> URLSessionDownloadTask {
        return genericDownloadTask(withRequest: URLRequest(url: url), authorization: authorization, completion: completion)
    }
    
    // MARK: Session Cancelling
    
    /// Cancels any current requests and the serivces URLSession.
    /// Call this before releasing the QantasNetworkService instance to prevent retain cycles.
    public func cancelAndInvalidateService() {
        session.invalidateAndCancel()
    }
    
    /// Finishes any current requests and the serivces URLSession.
    /// Call this before releasing the QantasNetworkService instance to prevent retain cycles.
    public func finishTasksAndInvalidate() {
        session.finishTasksAndInvalidate()
    }
    
    // MARK: Data Task Observing
    
    /// Post notification when a data task starts.
    ///
    /// - Parameter request: The URLRequest of the started task.
    func postStartTaskNotification(request: URLRequest?) {
        NotificationCenter.default.post(name: .networkTaskStarted, object: request, userInfo: nil)
    }
    
    /// Post notification when a data task completes.
    ///
    /// - Parameters:
    ///   - response: The `URLResponse` of the completed task.
    ///   - dataBody: The body of the completed task.
    func postCompleteTaskNotification(response: URLResponse?, dataBody: Data?) {
        guard let response = response else { return }
        var responseDict: [String: Any] = ["response": response]
        if let data = dataBody {
            responseDict["data"] = data
        }
        NotificationCenter.default.post(name: .networkTaskCompleted, object: nil, userInfo: responseDict)
    }
    
}
*/
