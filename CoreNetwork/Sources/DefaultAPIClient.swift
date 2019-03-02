//
//  DefaultAPIClient.swift
//  CoreNetwork
//
//  Created by Anas Alhasani on 11/15/18.
//  Copyright © 2018 Anas Alhasani. All rights reserved.
//

import Alamofire

public final class DefaultAPIClient: APIClient {
   
   public var configuration: ServiceConfigurator
   
   required public init(_ configuration: ServiceConfigurator = ServiceConfigurator()) {
      self.configuration = configuration
   }
   
   public func execute<Request: APIRequest, Response: Decodable>(_ request: Request, completion: @escaping Handler<Response>) {
      
      let urlRequest = request.urlRequest(in: self)
      
      let dataRequest = AlamofireManager.default.request(urlRequest)
      
      AlamofireManager.handleAuthChallenge()
      
      NetworkLogger.log(request: urlRequest)
      
      dataRequest.validate().responseJSON { response in
         
         NetworkLogger.log(data: response.data, response: response.response)
         
         if let error = response.error {
            completion(.failure(NetworkError.error(error.localizedDescription)))
         } else if let data = response.data {
            do {
               let object = try JSONDecoder().decode(Response.self, from: data)
               completion(.success(object))
            } catch {
               completion(.failure(NetworkError.decodingFailed))
            }
         } else {
            completion(.failure(NetworkError.unknown))
         }
      }
   }
   
}

