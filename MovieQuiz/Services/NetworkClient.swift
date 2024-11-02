import Foundation

struct NetworkClient {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        let conf = URLSessionConfiguration.default
        conf.timeoutIntervalForRequest = 30
        conf.timeoutIntervalForResource = 30
        let session = URLSession(configuration: conf)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}
