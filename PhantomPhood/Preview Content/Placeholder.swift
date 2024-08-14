//
//  Placeholder.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/13/24.
//

import Foundation

struct Placeholder {
    /// indexes 0...0
    static let placeDetails: [PlaceDetail] = [
        PlaceDetail(
            id: "645c1d1ab41f8e12a0d166bc",
            name: "Eleven Madison Park",
            amenity: nil,
            otherNames: [],
            description: "Eleven Madison Park embodies an urbane sophistication serving Chef Daniel Humm's modern, sophisticated French cuisine that emphasizes purity, simplicity and seasonal flavors and ingredients.  Daniel's delicate and precise cooking style is experienced through a constantly evolving menu. The restaurant's dramatically high ceilings and magnificent art deco dining room offer guests lush views of historic Madison Square Park and the Flatiron building. In addition to the main dining room, guests may also enjoy wine, beer, and cocktails, as well as an extensive bar menu in the restaurant's bar and Flatiron Lounge.\nIn November 2008, Eleven Madison Park was designated Grand Chef Relais & Châteaux, joining the ranks of one of the world's most exclusive associations of hotels and gourmet restaurants. In 2009, Eleven Madison Park received a Four Star Review from The New York Times. The restaurant was also awarded one Michelin star.",
            location: PlaceLocation(
                geoLocation: .init(lng: -73.9872074872255, lat: 40.7416907417333),
                address: "11 Madison Avenue",
                city: "New York",
                state: "NY",
                country: "US",
                zip: "10010"
            ),
            thumbnail: URL(string: "https://lh3.googleusercontent.com/p/AF1QipORpCE38GEBjvmFeP2fO3yrHfKLjVb_wswX-Y_N=s680-w680-h510"),
            phone: "+12128890905",
            website: nil,
            categories: [],
            priceRange: nil,
            scores: PlaceScores(
                overall: 4.5,
                drinkQuality: 4.363636363636363,
                foodQuality: 3.9342105263157894,
                atmosphere: 4.205882352941177,
                service: 4.196428571428571,
                value: 2.4025974025974026,
                phantom: 80.48771460737404
            ), activities: PlaceOverview.Activities(reviewCount: 0, checkinCount: 129),
            thirdParty: ThirdPartyResult(
                google: .init(
                    rating: 4.4,
                    reviewCount: 2766,
                    thumbnail: URL(string: "https://lh3.googleusercontent.com/places/ANXAkqEe7trH9rBeo2QGtiVHHEtaR-i3DuVwHBO6WRhUHNe5F--58obuq7rkkRrIM8yRn0-A2imVD3lHwMKiThV7neWq-uMpIPwqPXY=s4800-w800-h800"),
                    openingHours: .init(
                        openNow: true,
                        periods: [
                            .init(open: .init(day: 0, hour: 17, minute: 0), close: .init(day: 0, hour: 23, minute: 0)),
                            .init(open: .init(day: 1, hour: 17, minute: 30), close: .init(day: 1, hour: 22, minute: 0)),
                            .init(open: .init(day: 2, hour: 17, minute: 30), close: .init(day: 2, hour: 22, minute: 0)),
                            .init(open: .init(day: 3, hour: 17, minute: 30), close: .init(day: 3, hour: 22, minute: 0)),
                            .init(open: .init(day: 4, hour: 17, minute: 0), close: .init(day: 4, hour: 23, minute: 0)),
                            .init(open: .init(day: 5, hour: 17, minute: 0), close: .init(day: 5, hour: 23, minute: 0)),
                            .init(open: .init(day: 6, hour: 12, minute: 0), close: .init(day: 6, hour: 14, minute: 0)),
                            .init(open: .init(day: 6, hour: 17, minute: 0), close: .init(day: 6, hour: 23, minute: 0))
                        ],
                        weekdayDescriptions: [
                            "Monday: 5:30 – 10:00 PM",
                            "Tuesday: 5:30 – 10:00 PM",
                            "Wednesday: 5:30 – 10:00 PM",
                            "Thursday: 5:00 – 11:00 PM",
                            "Friday: 5:00 – 11:00 PM",
                            "Saturday: 12:00 – 2:00 PM, 5:00 – 11:00 PM",
                            "Sunday: 5:00 – 11:00 PM"
                        ]
                    )
                ),
                yelp: .init(
                    id: "nRO136GRieGtxz18uD61DA",
                    reviewCount: 2521,
                    rating: 4.3,
                    phone: "(212) 889-0905",
                    photos: [
                        MediaItem(id: UUID().uuidString, type: .image, src: URL(string: "https://s3-media4.fl.yelpcdn.com/bphoto/N91ZB8f0d39UAJeqvb89DA/o.jpg"), source: .yelp),
                        MediaItem(id: UUID().uuidString, type: .image, src: URL(string: "https://s3-media2.fl.yelpcdn.com/bphoto/X4gRFqcq51DQwDVTD4VLuQ/o.jpg"), source: .yelp),
                        MediaItem(id: UUID().uuidString, type: .image, src: URL(string: "https://s3-media1.fl.yelpcdn.com/bphoto/s_H7gm_Hwmz--O6bo1iU-A/o.jpg"), source: .yelp)
                    ],
                    url: URL(string: "https://www.yelp.com/biz/eleven-madison-park-new-york?adjust_creative=Qr6dz-OKyZdWhJoOCwy6Rw&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_lookup&utm_source=Qr6dz-OKyZdWhJoOCwy6R"),
                    thumbnail: URL(string: "https://s3-media4.fl.yelpcdn.com/bphoto/N91ZB8f0d39UAJeqvb89DA/o.jpg"),
                    categories: [
                        .init(title: "New American", alias: "newamerican"),
                        .init(title: "French", alias: "french"),
                        .init(title: "Cocktail Bars", alias: "cocktailbars")
                    ],
                    transactions: [],
                    price: "$$$$"
                )
            ),
            media: Self.media
        )
    ]
    
    /// indexes 0...3
    static let places: [PlaceEssentials] = [
        PlaceEssentials(
            id: "645c1d1ab41f8e12a0d166bc",
            name: "Eleven Madison Park",
            location: PlaceLocation(
                geoLocation: .init(lng: -73.9872074872255, lat: 40.7416907417333),
                address: "11 Madison Avenue",
                city: "New York",
                state: "NY",
                country: "US",
                zip: "10010"
            ),
            thumbnail: URL(string: "https://lh3.googleusercontent.com/p/AF1QipORpCE38GEBjvmFeP2fO3yrHfKLjVb_wswX-Y_N=s680-w680-h510"),
            categories: []
        ),
        PlaceEssentials(
            id: "645c1d1bb41f8e12a0d16eb4",
            name: "Blue Willow 夜来湘",
            location: .init(
                geoLocation: .init(lng: -73.976546, lat: 40.76292),
                address: "40 W 56th St",
                city: "New York",
                state: "NY",
                country: "US",
                zip: "10019"
            ),
            thumbnail: URL(string: "https://s3-media2.fl.yelpcdn.com/bphoto/1E59vOqmXZHBlJe0lLBHtA/o.jpg"),
            categories: []
        ),
        PlaceEssentials(
            id: "645c1d1ab41f8e12a0d167ae",
            name: "LOVE Korean BBQ",
            location: .init(
                geoLocation: .init(lng: -73.985056, lat: 40.747118),
                address: "319 5th Ave",
                city: "New York",
                state: "NY",
                country: "US",
                zip: "10016"
            ),
            thumbnail: URL(string: "https://s3-media1.fl.yelpcdn.com/bphoto/YhZhQy7rW4158pCwxB_-2Q/o.jpg"),
            categories: []
        ),
        PlaceEssentials(
            id: "65eafc78b56154da574fc9f8",
            name: "AEπ",
            location: .init(
                geoLocation: .init(lng: -122.0308473, lat: 36.9699794),
                address: "318 Maple St",
                city: "Santa Cruz",
                state: "CA",
                country: "US",
                zip: "95060"
            ),
            thumbnail: nil,
            categories: []
        )
    ]
    
    /// indexes 0...2
    static let users: [UserEssentials] = [
        UserEssentials(
            id: "645c8b222134643c020860a5",
            name: "Kia",
            username: "TheKia",
            verified: true,
            isPrivate: false,
            profileImage: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg"),
            progress: .init(level: 41, xp: 2669)
        ),
        UserEssentials(
            id: "645e7f843abeb74ee6248ced",
            name: "Nabeel",
            username: "naboohoo",
            verified: true,
            isPrivate: false,
            profileImage: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/profile.jpg"),
            progress: .init(level: 77, xp: 9964)
        ),
        UserEssentials(
            id: "653ac11038ac0fb4b50de348",
            name: "Meow",
            username: "TestMeow",
            verified: false,
            isPrivate: true,
            profileImage: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/653ac11038ac0fb4b50de348/profile.jpg"),
            progress: .init(level: 36, xp: 2088)
        ),
    ]
    
    /// indexes 0...0
    static let events: [Event] = [
        Event(
            id: "65eafc78b56154da574fc9fa",
            name: "AEπ",
            description: "Test description",
            logo: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/events/AEPi.png"),
            place: Self.places[3]
        ),
        Event(
            id: "662fa397516a809bf7b46f77",
            name: "Rich Ventures",
            description: "Lorem ipsum dolor sit amet.\nconsectetur adipiscing elit.\nsed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            logo: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/events/RichVenturesLogo.jpg"),
            place: Placeholder.places[0]
        )
    ]
    
    /// indexes 0...0
    static let placeReviews: [PlaceReview] = [
        PlaceReview(
            id: "6689d6a4407de95a2c9f136c",
            scores: .init(overall: 5, drinkQuality: 5, foodQuality: 5, atmosphere: 5, service: 5, value: 5),
            content: "Amazing vibes - all outdoors but there is shade everywhere so you can definitely come in on a hot day! They have their own pizza oven so def grab one of those. The drinks and food list is endless!\nDef come through for chill vibes with family and pets!\n🍻🍨🍕🍧",
            media: [],
            tags: ["OutdoorDining", "ShadedVenue", "PizzaOven"],
            recommend: true,
            language: "en",
            createdAt: .now,
            updatedAt: .now,
            userActivityId: "6689d6a4407de95a2c9f14b8",
            writer: Self.users[0],
            comments: [],
            reactions: ReactionsObject(
                total: [Reaction(reaction: "❤️", type: .emoji, count: 4), Reaction(reaction: "😍", type: .emoji, count: 2)],
                user: [UserReaction(id: "Test", reaction: "😍", type: .emoji, createdAt: .now)]
            )
        )
    ]
    
    static let comments: [Comment] = [
        Comment(
            id: "66a742c1e032859f1ad2c04b",
            content: "Cats lift in Istanbul 💪🏻🫡 @naboohoo",
            createdAt: .now,
            updatedAt: .now,
            author: Self.users[2],
            mentions: [
                .init(user: "645e7f843abeb74ee6248ced", username: "naboohoo")
            ],
            likes: 4,
            liked: true,
            repliesCount: 2,
            replies: []
        ),
    ]
    
    static let media: [MediaItem] = [
        MediaItem(
            id: "66a34918f6b5510331446b49",
            type: .image,
            src: URL(string: "https://mundo-app.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/images/20240726-bfe875f465d302bb.jpeg"),
            caption: "Cool coffee spot in Palo Alto! Got to get through an alleyway to get to the back",
            user: Self.users[1]
        ),
        MediaItem(
            id: "66845732a0902edb73a2ecbf",
            type: .video,
            src: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/videos/883f802809a6ac78f0e71687badae029.mp4"),
            caption: "",
            user: Self.users[1]
        ),
        MediaItem(
            id: "669273b71fe1b3b8887737c0",
            type: .image,
            src: URL(string: "https://mundo-app.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/images/20240713-a3fca1b047ab87fa.jpeg"),
            caption: "🔥🧊",
            user: Self.users[1]
        ),
        MediaItem(
            id: "6662afefc76f147424f81bc2",
            type: .video,
            src: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/659c7a7bdd0badea8734e7e6/videos/9aed66d4477a3b8253658932367d9fa2.mp4"),
            caption: "",
            user: Self.users[1]
        ),
    ]
}
