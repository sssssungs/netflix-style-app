//
//  SearchViewController.swift
//  MyNetflix
//
//  Created by joonwon lee on 2020/04/02.
//  Copyright © 2020 com.joonwon. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    
    @IBOutlet weak var resultCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}


extension SearchViewController: UISearchBarDelegate {
    // 키보드 내리는 함수
    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
        // 키보드 올라오는게 첫번째 responder로 지정되어 있으므로 resign 시킨다.
        // 첫번째 Responder란 정확히 무엇인가 ?
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 키보드 없애기
        dismissKeyboard()
        
        // 검색어 있는지 확인
        // guard let [A] else [B]
        // A를 만족하지 않는 경우 B를 실행
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else {
            return
        }
        
        // 네트워킹
        // search term 을 가지고 영화검색.
        // 검색 api 적용필요
        // 검색 결과를 가져올 movie model 이 필요, response model 필요
        // 결과를 받아와서 collection view로 표현
        SearchAPI.search(searchTerm) { movies in
            // collection view 로 표현하기
            print("---> 몇개???? \(movies.count), 첫번째꺼 ? \(movies.first?.title)")
//            movies
        }
        print("search term ====> \(searchTerm)")

    }
}

class SearchAPI {
    // @ escaping : completion 안에 있는 코드블럭이 밖에서도 실행될수 있다 (?)
    // static 으로 만들면 인스턴스가 없이 그냥 class type에서 바로 접근가능 ex) SearchAPI.search()
    static func search(_ term: String, completion: @escaping ([Movie]) -> Void) {
        // url session
        let session = URLSession(configuration: .default)
        
        // url setting
        var urlComponents = URLComponents(string: "http://itunes.apple.com/search?")!
        let mediaQuery = URLQueryItem(name: "media", value: "movie")
        let entityQuery = URLQueryItem(name: "entity", value: "movie")
        let termQuery = URLQueryItem(name: "term", value: term)
        urlComponents.queryItems?.append(mediaQuery)
        urlComponents.queryItems?.append(entityQuery)
        urlComponents.queryItems?.append(termQuery)
        let requestURL = urlComponents.url!
        
        let dataTask = session.dataTask(with: requestURL) { data, response, error in
            let successRange = 200..<300 // success code 범위 지정 200~299
            
            guard error == nil,
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                successRange.contains(statusCode) else { // 문제가 있는 경우에는 여기
                    completion([])
                    return
            }
            
            guard let resultData = data else {
                completion([])
                return
            }
            let movies = SearchAPI.parseMovies(resultData)
//            print("======>>>> count: \(movies.count)")
            completion(movies)
        }
        
        dataTask.resume() // url request start
    }
    
    static func parseMovies(_ data: Data) -> [Movie] {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(Response.self, from: data)
            let movies = response.movies
            return movies
        } catch let error {
            print("-----> parsing error : \(error.localizedDescription)")
            return []
        }
    }
    
}

struct Response: Codable { // codable : json parsing 쉽게 하기위해 사용
    let resultCount: Int
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case resultCount
        case movies = "results" // results 로 가지는것을 movies 로 넣어라
    }
}

struct Movie: Codable {
    let title: String
    let director: String
    let thumbnailPath: String
    let previewURL: String
 
    enum CodingKeys: String, CodingKey {
        case title = "trackName"
        case director = "artistName"
        case thumbnailPath = "artworkUrl100"
        case previewURL = "previewUrl"
    }
}
