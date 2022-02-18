/*:

## Fueled Swift Exercise

A blogging platform stores the following information that is available through separate API endpoints:
+ user accounts
+ blog posts for each user
+ comments for each blog post

### Objective
The organization needs to identify the 3 most engaging bloggers on the platform. Using only Swift and the Foundation library, output the top 3 users with the highest average number of comments per post in the following format:

&nbsp;&nbsp;&nbsp; `[name]` - `[id]`, Score: `[average_comments]`

Instead of connecting to a remote API, we are providing this data in form of JSON files, which have been made accessible through a custom Resource enum with a `data` method that provides the contents of the file.

### What we're looking to evaluate
1. How you choose to model your data
2. How you transform the provided JSON data to your data model
3. How you use your models to calculate this average value
4. How you use this data point to sort the users

*/

import Foundation

/*:
1. First, start by modeling the data objects that will be used.
*/
class User: Decodable {
    let id: Int
    let name: String
    var avgCmtCount: Float16
    
    enum UserKeys: String, CodingKey {
        case id
        case name
      }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.avgCmtCount = 0
    }
}

struct Post: Decodable {
    let id: Int
    let userId: Int
    
    enum PostKeys: String, CodingKey {
        case id
        case userId
      }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PostKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.userId = try container.decode(Int.self, forKey: .userId)
    }
}

struct Comment: Decodable {
    let id: Int
    let postId: Int
    
    enum CommentKeys: String, CodingKey {
        case id
        case postId
      }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CommentKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.postId = try container.decode(Int.self, forKey: .postId)
    }
}

/*:
2. Next, decode the JSON source using `Resource.users.data()`.
*/
var userData: [User] = []
var postData: [Post] = []
var commentData: [Comment] = []

do {
    let decoder = JSONDecoder()
    userData = try decoder.decode([User].self, from: Resource.users.data())
    postData = try decoder.decode([Post].self, from: Resource.posts.data())
    commentData = try decoder.decode([Comment].self, from: Resource.comments.data())
} catch {
    print (error)
}

/*:
3. Next, use your populated models to calculate the average number of comments per user.
*/

// How many comments a post has.
var commentCountPerPostDict = [Int: Int]()  //[postId: commentsCount]
for comment in commentData {
    commentCountPerPostDict[comment.postId] = (commentCountPerPostDict[comment.postId] ?? 0) + 1
}

// How many comments under a user -> [userId: totalCommentCount]
var userTotalCommentDict = [Int: Int]()
// How many posts under a user -> [userId: totalPostCount]
var userTotalPostDict = [Int: Int]()
for post in postData {
    let postCommentCount = commentCountPerPostDict[post.id] ?? 0
    userTotalCommentDict[post.userId] = (userTotalCommentDict[post.userId] ?? 0) + postCommentCount
    userTotalPostDict[post.userId] = (userTotalPostDict[post.userId] ?? 0) + 1
}

// Calculating average number of comments of a post per user.
for user in userData {
    let totalPostCount = userTotalPostDict[user.id] ?? 0
    let totalCommentCount = userTotalCommentDict[user.id] ?? 0
    user.avgCmtCount = (totalCommentCount == 0 || totalPostCount == 0) ? 0 : Float16(totalCommentCount)/Float16(totalPostCount);
}

/*:
4. Finally, use your calculated metric to find the 3 most engaging bloggers, sort order, and output the result.
*/

userData.sorted{ $0.avgCmtCount > $1.avgCmtCount }.prefix(3).map({
    print("[\($0.name)] - [\($0.id)], Score: [\($0.avgCmtCount)]")
})



