//
//  Session.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
//  is subject to the LINE Developers Agreement [http://terms2.line.me/LINE_Developers_Agreement].
//  This copyright notice shall be included in all copies or substantial portions of the software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// Represents a session for sending a `Request` object through a `URLSession` object for the LINE Platform. This
/// class respects the `adapters` and `pipelines` properties of the `Request` protocol, to create proper requests
/// and handle the response in the designed way.
public class Session {
    
    /// The result of response `handle` method could give.
    ///
    /// - value: A final result of `Response`. It means the response pipelines finished without problem.
    /// - action: An action should applied to current handling process. See `HandleAction` for more.
    enum HandleResult<T> {
        
        /// Handle action should by applied.
        ///
        /// - restart: Restart the whole request without modifying original pipelines.
        /// - restartWith: Restart the whole request with the given pipelines.
        /// - stop: Stop handling process and an error is reported.
        enum HandleAction {
            case restart
            case restartWith(pipelines: [ResponsePipeline])
            case stop(Error)
        }
        
        case value(T)
        case action(HandleAction)
    }
    
    static var _shared: Session?
    
    /// The shared instance of `Session`. Access this value after you setup the LINE SDK.
    /// Otherwise, your app will be trapped.
    public static var shared: Session {
        return guardSharedProperty(_shared)
    }
    
    let session: URLSession
    let delegate: SessionDelegateType
    
    convenience init(configuration: LoginConfiguration) {
        let delegate = SessionDelegate()
        self.init(configuration: configuration, delegate: delegate)
    }
    
    init(configuration: LoginConfiguration, delegate: SessionDelegateType) {
        self.delegate = delegate
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: delegate, delegateQueue: nil)
    }
    
    /// Sends a `Request` object with the underlying session.
    ///
    /// - Parameters:
    ///   - request: A `Request` object which defines necessary information for the request.
    ///   - callbackQueue: A queue option to be used when `completion` is invoked. The default value is 
    ///                    `.currentMainOrAsync`.
    ///   - completion: The completion closure to be invoked when the request has been sent.
    /// - Returns: The `SessionTask` object that represents the task.
    @discardableResult
    public func send<T: Request>(
        _ request: T,
        callbackQueue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: ((Result<T.Response, LineSDKError>) -> Void)? = nil) -> SessionTask?
    {
        return send(request, callbackQueue: callbackQueue, pipelines: nil, completionHandler: completion)
    }
    
    /// Send a `Request` object with underlying session.
    ///
    /// - Parameters:
    ///   - request: A `Request` object which defines necessary information for the request.
    ///   - callbackQueue: A queue options on which the `completion` closure should be executed.
    ///                    Default is `.currentMainOrAsync`.
    ///   - pipelines: The pipelines should be used to override `request.pipelines`. When provided, the `Session` will
    ///                ignore the Default is `nil`,
    ///   - completion: The completion closure to be invoked when the session sending finishes.
    /// - Returns: The `SessionTask` object that represents the task.
    @discardableResult
    func send<T: Request>(
        _ request: T,
        callbackQueue: CallbackQueue = .currentMainOrAsync,
        pipelines: [ResponsePipeline]?,
        completionHandler completion: ((Result<T.Response, LineSDKError>) -> Void)? = nil) -> SessionTask?
    {
        let urlRequest: URLRequest
        do {
            urlRequest = try create(request)
        } catch {
            callbackQueue.execute { completion?(.failure(error.sdkError)) }
            return nil
        }
        
        let sessionTask = SessionTask(session: session, request: urlRequest)
        sessionTask.onResult.delegate(on: self) { (self, value) in
            switch value {
            case (_, _, let error?):
                let error = LineSDKError.responseFailed(reason: .URLSessionError(error))
                callbackQueue.execute { completion?(.failure(error)) }
            case (let data?, let response as HTTPURLResponse, _):
                do {
                    let pipelines = pipelines ?? (request.prefixPipelines ?? []) + request.pipelines
                    try self.handle(
                        request: request,
                        data: data,
                        response: response,
                        pipelines: pipelines,
                        fullPipelines: pipelines)
                    {
                        result in
                        
                        switch result {
                        case .value(let value):
                            callbackQueue.execute { completion?(.success(value)) }
                        case .action(.stop(let error)):
                            callbackQueue.execute { completion?(.failure(error.sdkError)) }
                        case .action(.restart):
                            self.send(
                                request,
                                callbackQueue: callbackQueue,
                                pipelines: nil,
                                completionHandler: completion)
                        case .action(.restartWith(let pipelines)):
                            self.send(
                                request,
                                callbackQueue: callbackQueue,
                                pipelines: pipelines,
                                completionHandler: completion)
                        }
                    }
                } catch {
                    callbackQueue.execute { completion?(.failure(error.sdkError)) }
                }
            default:
                let error = LineSDKError.responseFailed(reason: .nonHTTPURLResponse)
                callbackQueue.execute { completion?(.failure(error)) }
            }
        }
        
        // `shouldTaskStart` is only for testing purpose, to prevent a real request and
        // intercept with a predefined response for returning.
        if delegate.shouldTaskStart(sessionTask) {
            delegate.add(sessionTask)
            sessionTask.resume()
        }
        
        return sessionTask
    }
    
    /// Create a request based on `Request` definition.
    ///
    /// - Parameter request: `Request` definition to create the real `URLRequest`.
    /// - Returns: Configured request.
    /// - Throws: Any error might happen during creating the request.
    func create<T: Request>(_ request: T) throws -> URLRequest {
        let url = request.baseURL
            .appendingPathComponentIfNotEmpty(request)
            .appendingPathQueryItems(request)

        let urlRequest = URLRequest(
            url: url,
            cachePolicy: request.cachePolicy,
            timeoutInterval: request.timeout)
        
        let adapters = request.adapters + (request.suffixAdapters ?? [])
        let adaptedRequest = try adapters.reduce(urlRequest) { r, adapter in
            try adapter.adapted(r)
        }
        return adaptedRequest
    }
    
    /// Handle the result of a finished `SessionTask` with pipelines.
    ///
    /// - Parameters:
    ///   - request: The corresponding original `Request` of this response.
    ///   - data: `Data` received for the response.
    ///   - response: An `HTTPURLResponse` object from `URLSession` delegate.
    ///   - pipelines: Pipelines should be applied to current handle process.
    ///   - fullPipelines: Full pipelines of original request.
    ///   - done: Invoked when a handling result prepared, to determine the next pipeline step.
    /// - Throws: The error occurs during the handling process.
    func handle<T: Request>(
        request: T,
        data: Data,
        response: HTTPURLResponse,
        pipelines: [ResponsePipeline],
        fullPipelines: [ResponsePipeline],
        done: @escaping ((HandleResult<T.Response>) throws -> Void)) throws
    {
        guard !pipelines.isEmpty else {
            Log.fatalError("The pipeline is already empty but request does not be parsed." +
                "Please at least set a terminator pipeline to the request `pipelines` property.")
        }
        var leftPipelines = pipelines
        
        // Handle the first pipeline.
        let pipeline = leftPipelines.removeFirst()
        
        // Recursive calling on `handle` in this `switch` statement might be an issue when there are tons of
        // redirectors in the pipeline. However, it should not happen at all in a foreseeable future. If there
        // is any problem on it, we might need a pipeline queue to break the recursion.
        //
        switch pipeline {
        case .redirector(let redirector):
            // The redirector decides to not apply. Go next.
            guard redirector.shouldApply(request: request, data: data, response: response) else {
                try self.handle(
                    request: request,
                    data: data,
                    response: response,
                    pipelines: leftPipelines,
                    fullPipelines: fullPipelines,
                    done: done)
                return
            }
            // Otherwise, do a redirection following the redirector action.
            try redirector.redirect(request: request, data: data, response: response) { action in
                switch action {
                case .continue:
                    // Normally continue to next pipeline in handling process.
                    try self.handle(
                        request: request,
                        data: data,
                        response: response,
                        pipelines: leftPipelines,
                        fullPipelines: fullPipelines,
                        done: done)
                case .continueWith(let newData, let newResponse):
                    // Continue with modified data or response.
                    try self.handle(
                        request: request,
                        data: newData,
                        response: newResponse,
                        pipelines: leftPipelines,
                        fullPipelines: fullPipelines,
                        done: done)
                case .restart:
                    // Tell `Session` to restart the request.
                    try done(.action(.restart))
                case .restartWithout(let pipeline):
                    // Tell `Session` to restart the request, but exclude a certain pipeline.
                    let pipelines = fullPipelines.filter { $0 != pipeline }
                    try done(.action(.restartWith(pipelines: pipelines)))
                case .stop(let error):
                    try done(.action(.stop(error)))
                }
            }
            return
        case .terminator(let terminator):
            do {
                let value = try terminator.parse(request: request, data: data)
                try done(.value(value))
            } catch {
                throw LineSDKError.responseFailed(reason: .dataParsingFailed(T.Response.self, data, error))
            }
        }
    }
}

protocol SessionDelegateType: URLSessionDataDelegate {
    func add(_ task: SessionTask)
    func remove(_ task: URLSessionTask)
    func task(for task: URLSessionTask) -> SessionTask?
    func shouldTaskStart(_ task: SessionTask) -> Bool
}

// A thread-safe holder for session tasks.
class SessionDelegate: NSObject {
    private var tasks: [Int: SessionTask] = [:]
    private let lock = NSLock()
    
    func add(_ task: SessionTask) {
        lock.lock()
        defer { lock.unlock() }
        tasks[task.task.taskIdentifier] = task
    }
    
    func remove(_ task: URLSessionTask) {
        lock.lock()
        defer { lock.unlock() }
        tasks.removeValue(forKey: task.taskIdentifier)
    }
    
    func task(for task: URLSessionTask) -> SessionTask? {
        lock.lock()
        defer { lock.unlock() }
        return tasks[task.taskIdentifier]
    }
    
    func shouldTaskStart(_ task: SessionTask) -> Bool {
        return true
    }
}

extension SessionDelegate: SessionDelegateType {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = self.task(for: dataTask) else {
            return
        }
        task.didReceiveData(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let dataTask = task as? URLSessionDataTask, let task = self.task(for: dataTask) else {
            return
        }
        remove(dataTask)
        task.onResult.call((task.mutableData, dataTask.response, error))
    }
    
}

typealias SessionTaskResult = (Data?, URLResponse?, Error?)

/// Represents a task of a `Session` object.
public class SessionTask {
    let request: URLRequest
    let session: URLSession
    let task: URLSessionDataTask
    
    var mutableData: Data
    
    let onResult = Delegate<SessionTaskResult, Void>()
    
    init(session: URLSession, request: URLRequest) {
        self.session = session
        self.request = request
        
        self.task = session.dataTask(with: request)
        self.mutableData = Data()
    }
    
    func resume() {
        task.resume()
    }
}

extension SessionTask {
    func didReceiveData(_ data: Data) {
        mutableData.append(data)
    }
}

extension URL {
    func appendingPathComponentIfNotEmpty<R: Request>(_ request: R) -> URL {
        let path = request.path
        return path.isEmpty ? self : appendingPathComponent(path)
    }

    func appendingPathQueryItems<R: Request>(_ request: R) -> URL {
        guard request.method != .get else {
            return self
        }
        guard let items = request.pathQueries else {
            return self
        }
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = items
        return components.url ?? self
    }
}
