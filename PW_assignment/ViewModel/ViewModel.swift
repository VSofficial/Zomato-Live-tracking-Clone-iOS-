//
//  ViewModel.swift
//  PW_assignment
//
//  Created by Varun Sharma on 20/04/24.
//

import Foundation
import UIKit

class ViewModel {
    
    //Function for fetching API Responses
    func fetchData(completion: @escaping (Result<OrderList, Error>) -> Void) {
        
        let apiUrlString = "https://6622938627fcd16fa6ca3ed8.mockapi.io/food/updated"
        guard let apiUrl = URL(string: apiUrlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: apiUrl) { data, response, error in
         
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                return
            }
          
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(OrderList.self, from: responseData)
               
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }

        dataTask.resume()
    }
    
    }
