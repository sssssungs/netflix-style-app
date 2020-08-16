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
    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 키보드 없애기
        dismissKeyboard()
        
        // 검색어 있는지 확인
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
        
        var urlComponents = URLComponents(string: "http://itunes.apple.com/search?")!
        let mediaQuery = URLQueryItem(name: "media", value: "movie")
        let entityQuery = URLQueryItem(name: "entity", value: "movie")
        let termQuery = URLQueryItem(name: "term", value: term)
        
        urlComponents.queryItems?.append(mediaQuery)
        urlComponents.queryItems?.append(entityQuery)
        urlComponents.queryItems?.append(termQuery)
        
        let requestURL = urlComponents.url!
        
        let dataTask = session.dataTask(with: requestURL) { data, response, error in
            let successRange = 200..<300
            
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
            
            // parsing 해서 completion 전달
            let string = String(data: resultData, encoding: .utf8)
            print("---> search result \(string)")
//            completion([Movie])
            
        }
        dataTask.resume() // url request start
    }
}

struct Response {
    
}

struct Movie {
    
}
