//
//  Model.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/04/21.
//

import Foundation

struct Board: Codable { // response
    var sell: Bool?
    var __v: Int?
    var _id: String?
    var author: String?
    var postid: Int?
    var title: String?
    var content: String?
    var images: [String]?
    var profileImage: String?
    var category: String?
    var price: Int?
    var view: Int?
    var interest: Int?
    var needPeople: Int?
    var nowPeople: Int?
    var link: String?
    var tags: [String]?
    var createdAt: String?
    var updatedAt: String?
    var location: Location?
    var email: String?
    
    enum CodingKeys: String, CodingKey {
        case sell
        case __v
        case _id
        case author
        case title
        case content
        case images
        case category
        case price
        case view
        case needPeople
        case nowPeople
        case link
        case postid
        case tags
        case createdAt
        case updatedAt
        case interest = "likes"
        case profileImage = "profileImg"
        case location
        case email

    }
    
    init(__v: Int, _id: String, author: String, postid: Int, title: String, content: String, images: [String], profileImage: String, category: String, price: Int, view: Int, interest: Int, needPeople: Int, nowPeople: Int, link: String, tags: [String], createdAt: String, updatedAt: String, location: Location, email: String) {
      
        self.__v = __v
        self._id = _id
        self.author = author
        self.postid = postid
        self.title = title
        self.content = content
        self.images = images
        self.profileImage = profileImage
        self.category = category
        self.price = price
        self.view = view
        self.interest = interest
        self.needPeople = needPeople
        self.nowPeople = nowPeople
        self.link = link
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.location = location
        self.email = email
        
    }
    
}

struct BoardResponse: Codable { // response
    var __v: Int = 0
    var _id: String = ""
    var author: String = ""
    var postid: Int = 0
    var title: String = "" // 글 제목
    var content: String = "" // 글 내용
    var images: [String] = []
    var profileImage: String = ""  // 글 대표 이미지
    var category: String = "" // 글 카테고리
    var price: Int = 0 //가격
    var view: Int = 0 // 조회수
    var interest: Int = 0 // 관심수
    var needPeople: Int = 0// 모집 인원
    var nowPeople: Int = 0 // 모집된 인원
    var link: String = ""
    var tags: [String] = []
    var createdAt: String = ""
    var updatedAt: String = ""
    var location: Location = Location(_id: "", coordinates: [0,0], type: "")
    var email: String = ""
    
    enum CodingKeys: String, CodingKey {
        case __v
        case _id
        case author
        case title
        case content
        case images
        case category
        case price
        case view
        case needPeople
        case nowPeople
        case link
        case postid
        case tags
        case createdAt
        case updatedAt
        case interest = "likes"
        case profileImage = "profileImg"
        case location
        case email

    }
    
}



struct Users: Codable {
    var __v: Int = 0
    var _id: String = ""
    var email: String = "" // 유저 이메일
    var name: String = "" //유저 네임
    var authProvider: String = "" //소셜 로그인 정보
    var isSeller: Bool = false//판매 권한
    var chatRoomList: [Int] = [] // 참여 중인 채팅 방 ID
    var nickName: String = "" //유저 닉네임
    var profileImageUrl: String = "" // 유저 프로필 이미지 url
    var followers: [String] = [] //내가 follow 하는 nickName
    var following: [String] = []//내가 following 하는 사람
    var createdAt: String = ""
    var updatedAt: String = ""
    var deviceToken: String = ""
    //유저 위치
    var location: Location = Location()
    var posts:[Int] = []
    var likes: [Int] = []
    
    enum CodingKeys: String, CodingKey {
        case __v
        case _id
        case email
        case name
        case authProvider
        case isSeller
        case chatRoomList = "chatroomList"
        case nickName = "nickname"
        case profileImageUrl = "profileImg"
        case followers
        case following
        case createdAt
        case updatedAt
        case deviceToken
        case location
        case posts
        case likes

    }
    
//    init(__v: Int, _id: String, email: String, name: String, authProvider: String, isSeller: Bool, chatRoomList: [Int], nickName: String, profileImageUrl: String, followers: [String], following: [String], createdAt: String, updatedAt: String, deviceToken: String, location: Location, posts:[Int], likes: [Int] ) {
//
//        self.__v = __v
//        self._id = _id
//        self.email = email
//        self.name = name
//        self.authProvider = authProvider
//        self.isSeller = isSeller
//        self.chatRoomList = chatRoomList
//        self.nickName = nickName
//        self.profileImageUrl = profileImageUrl
//        self.followers = followers
//        self.following = following
//        self.createdAt = createdAt
//        self.updatedAt = updatedAt
//        self.deviceToken = deviceToken
//        self.location = location
//        self.posts = posts
//        self.likes = likes
//
//    }
    
}

struct Location: Codable {
    var _id: String = ""
    var coordinates: [Double] = []
    var type: String = ""
    var dictionary: [String: Any] {
        return ["coordinates": [coordinates]]
    }
}

extension Location {
    init?(dictionary: [String:Any]) {
        guard let location = dictionary["coordinates"] as? [Double] else { return nil }
        self.init(coordinates: location)
    }
}

//juso
struct JusoResponse: Codable {
    var results: JusoResults!
}

struct JusoResults: Codable {
    var common: Common!
    var juso: [Juso]!
}

struct Common: Codable {
    var errorCode: String!
    var currentPage: String!
    var totalCount: String!
    var errorMessage: String!
}

struct Juso: Codable {
    var roadAddr: String!
    var jibunAddr: String!
}

struct Category {
    var categoryImage: String
    var categoryText: String
}

//struct PostBoard: Codable {
//    var author : String? //테스트용 아이디 이용
//    var title : String?
//    var content : String?
//    var link : String?
//    var needPeople : String? //없으면 post 불가, 임의로 값 설정
//    var price : String?
//    var category : String?
//    var images : [Data]?
//}


struct PostBoard: Codable { // for request
    var author : String = "" //테스트용 아이디 이용
    var title : String = ""
    var content : String = ""
    var link : String = ""
    var needPeople : String = "" //없으면 post 불가, 임의로 값 설정
    var price : Int = 0
    var category : String = ""
    var images : [Data] = []
    var location : Location? = Location(dictionary: ["coordinates" : [0, 0]])
}
