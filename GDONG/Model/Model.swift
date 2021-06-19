//
//  Model.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/04/21.
//

import Foundation


struct Board {
    var profileImage: String
    var title: String // 글 제목
    var content: String // 글 내용
    var date: String // 글 작성 날짜
    var category: String // 글 카테고리
    var price: String //가격
    var view: Int // 조회수
    var interest: Int // 관심수
    var needPeople: Int // 모집 인원
    var nowPeople: Int // 모집된 인원
    var likeButton: Bool // 좋아요 한 글
    
}

struct User {
    var isNomal: Bool
    var usetName: String
    var userEmail: String
    var userImage: String
    var userLocation: String
    var likePage: [String]
    var chatRoomList: [Int] // 참여 중인 채팅 방 ID
}

struct Category {
    var categoryImage: String
    var categoryText: String
}

struct PostBoard: Codable {
    var author : String? //테스트용 아이디 이용
    var title : String?
    var content : String?
    var link : String?
    var needPeople : String? //없으면 post 불가, 임의로 값 설정
    var price : String?
    var category : String?
    var images : [Data]?
}
