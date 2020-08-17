//
//  Photos.swift
//  VirtualTouristUdacity
//
//  Created by nF ™ on 18/08/2020.
//  Copyright © 2020 nF ™. All rights reserved.
//
import Foundation

// MARK: - Artist
struct Flicker: Codable {
    let photos: Photos?
    let stat, name: String?
    let founded: Int?
    let members: [String]?
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}

// MARK: - Album
struct Album: Codable {
    let name: String
    let artist: ArtistClass
    let tracks: [Track]
}

// MARK: - ArtistClass
struct ArtistClass: Codable {
    let name: String
    let founded: Int
    let members: [String]
}

// MARK: - Track
struct Track: Codable {
    let name: String
    let duration: Int
}
