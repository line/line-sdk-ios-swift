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

class Session: LazySingleton {
    
    enum HandleAction {
        case restart
        case restartWith(pipelines: [ResponsePipeline])
        case stop(Error)
    }
    
    enum HanldeResult<T> {
        case value(T)
        case action(HandleAction)
    }
    
    static var _shared: Session?
    
    let baseURL: URL
    let session: URLSession
    let delegate: SessionDelegateType
    
    let callbackQueue = CallbackQueue.asyncMain
    
    convenience init(configuration: LoginConfiguration) {
        let delegate = SessionDelegate()
        self.init(configuration: configuration, delegate: delegate)
    }
    
    init(configuration: LoginConfiguration, delegate: SessionDelegateType) {
        baseURL = URL(string: "https://\(configuration.APIHost)")!
        self.delegate = delegate
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: delegate, delegateQueue: nil)
    }
    
    func send<T>(_ request: T, handler: ((Result<T.Response>) -> Void)?) where T : Request {
        send(request, callbackQueue: nil, handler: handler)
    }
    
    @discardableResult
    func send<T: Request>(
        _ request: T,
        callbackQueue: CallbackQueue? = nil,
        pipelines: [ResponsePipeline]? = nil,
        handler: ((Result<T.Response>) -> Void)? = nil) -> SessionTask?
    {
        let callbackQueue = callbackQueue ?? self.callbackQueue
        
        let urlRequest: URLRequest!
        do {
            urlRequest = try create(request)
        } catch {
            callbackQueue.execute { handler?(.failure(error)) }
            return nil
        }
        
        let sessionTask = SessionTask(session: session, request: urlRequest)
        sessionTask.onResult.delegate(on: self) { (self, value) in
            switch value {
            case (_, _, let error?):
                let error = LineSDKError.responseFailed(reason: .URLSessionError(error))
                callbackQueue.execute { handler?(.failure(error)) }
            case (let data?, let response as HTTPURLResponse, _):
                do {
                    let pipelines = pipelines ?? request.pipelines
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
                            callbackQueue.execute { handler?(.success(value)) }
                        case .action(.restart):
                            self.send(request, callbackQueue: callbackQueue, handler: handler)
                        case .action(.restartWith(let pipelines)):
                            self.send(request, callbackQueue: callbackQueue, pipelines: pipelines, handler: handler)
                        case .action(.stop(let error)):
                            callbackQueue.execute { handler?(.failure(error)) }
                        }
                    }
                } catch {
                    callbackQueue.execute { handler?(.failure(error)) }
                }
            default:
                let error = LineSDKError.responseFailed(reason: .nonHTTPURLResponse)
                callbackQueue.execute { handler?(.failure(error)) }
            }
        }
        
        if delegate.shouldTaskStart(sessionTask) {
            delegate.add(sessionTask)
            sessionTask.resume()
        }
        
        return sessionTask
    }
    
    func create<T: Request>(_ request: T) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(request.path)
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        
        let adaptedRequest = try request.adapters.reduce(urlRequest) { r, adapter in
            try adapter.adapted(r)
        }
        return adaptedRequest
    }
    
    func handle<T: Request>(
        request: T,
        data: Data,
        response: HTTPURLResponse,
        pipelines: [ResponsePipeline],
        fullPipelines: [ResponsePipeline],
        done: @escaping ((HanldeResult<T.Response>) throws -> Void)) throws
    {
        guard !pipelines.isEmpty else {
            Log.fatalError("The pipeline is already empty but request does not be parsed." +
                "Please at least set a terminator pipeline to the request `pipelines` property.")
        }
        var leftPipelines = pipelines
        let pipeline = leftPipelines.removeFirst()
        switch pipeline {
        case .redirector(let redirector):
            guard redirector.shouldApply(request: request, data: data, response: response) else {
                // Recursive calling on `handle` might be an issue when there are tons of
                // redirectors in the pipeline. However, it should not happen at all in a
                // foreseeable future. If there is any problem on it, we might need a pipeline
                // queue to break the recursiving.
                try self.handle(
                    request: request,
                    data: data,
                    response: response,
                    pipelines: leftPipelines,
                    fullPipelines: fullPipelines,
                    done: done)
                return
            }
            try redirector.redirect(request: request, data: data, response: response) { action in
                switch action {
                case .continue:
                    try self.handle(
                        request: request,
                        data: data,
                        response: response,
                        pipelines: leftPipelines,
                        fullPipelines: fullPipelines,
                        done: done)
                case .restart:
                    try done(.action(.restart))
                case .restartWithout(let pipeline):
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
                throw LineSDKError.responseFailed(reason: .dataParsingFailed(error))
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

class SessionTask {
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
