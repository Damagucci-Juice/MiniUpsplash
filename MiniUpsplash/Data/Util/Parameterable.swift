//
//  Parameterable.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//


import Alamofire

protocol Parameterable {
    func makeParam() -> Parameters
}

extension TopicRequestDTO {
    func makeParam() -> Parameters {
        var result: Parameters = [:]
        if let page { result.updateValue(page, forKey: "page") }
        return result
    }
}

extension SearchRequestDTO {
    func makeParam() -> Parameters {
        var result: Parameters = [ "query" : query ]
        if let page { result.updateValue(page, forKey: "page") }
        if let perPage { result.updateValue(perPage, forKey: "per_page") }
        if let orderBy { result.updateValue(orderBy.paramValue, forKey: "order_by") }
        if let color { result.updateValue(color.paramValue, forKey: "color") }
        return result
    }
}