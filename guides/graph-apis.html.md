---
title: "Graph APIs"
description: "Using LINE Graph APIs to get users' social graph, like friends and groups."
---

<div class="Md108FrameNote">
  <p><span class="Md07TextBold">Note: </span>Graph APIs are now <b>still in closed beta</b>, only for the internal partner using. They are not yet prepared for the public and <b>we do not accept applications for them yet</b>. Please keep an eye on it and we will inform you if the state changes in future.</p>
</div>

## Permissions

You need `.friends` to make friends related API requests, and `.groups` to make groups related API requests:

```swift
LoginManager.shared.login(permissions: [.friends, .groups], in: self) { result in
    // Handling the login result...
}
```

## Get Friends List of Current User

Once your user authorized with the `.friends` permission, you could access the friends list by calling:

```swift
API.getFriends(pageToken: nil) {
    result in
    switch result {
    case .success(let response):
        let friendsInPageOne = response.friends // friendsInPageOne: [User]
        let nextPageToken = response.cpageToken  // nextPageToken: String?
    case .failure(let error):
        print(error)
    }
}
```

### Paginated Result

A paginated result will be returned from this API. By passing `nil` as the `pageToken`, the first page of friends list will be returned. If `nextPageToken` in the response is a non-nil value, it means that there is at least another page to load. You could call `API.getFriends` again with the token value to get the next page:

```swift
guard let nextPageToken = nextPageToken else {
    print("All pages are loaded.")
    return
}
API.getFriends(pageToken: nextPageToken) {
    result in
    //...
}
```

We suggest you to follow the same pagination way to construct your UI (usually a table view or a collection view), to get better performance, instead of looping this method to get all friends at once.

### Sorting Result

<!--TODO onevcat: Waiting for confirming with API server about supported sorting method-->

## Get Groups List of Current User

Once your user authorized with the `.groups` permission, you could access the list of groups  of that user belongs to.

```swift
API.getGroups(pageToken: nil) {
        result in
        switch result {
        case .success(let response):
            let groupsInPageOne = response.groups // groupsInPageOne: [Group]
            let nextPageToken = response.pageToken  // nextPageToken: String?
        case .failure(let error):
            print(error)
        }
    }
```

See "Paginated Result" above to check how to use `nextPageToken` to get next page if there it is.

## Get Users Authorized the Same Channel

Sometimes, compared to getting full user social graph, you may be more interested in getting a subset of friends who also authorized the same channel. It would be helpful if you want to construct a leaderboard or any other system with interaction between your app users. We call this subset as the **approved friends** for the same channel.

```swift
API.getApproversInFriends(pageToken: nil) {
    result in
    // ...
}
```

> Assume the current user has three friends *A*, *B* and *C*. If *A* and *B* also authorized your channel, the approved friends are *A* and *B*, and they will be returned in the result of `API.getApproversInFriends`.  However, *C* will not be contained in the response. 
> 
> While all *A*, *B* and *C* will be returned in `API.getFriends`.

To get **approved users** from a group, you can use:

```swift
API.getApproversInGroup(groupID: "123", pageToken: nil) {
    result in
    // ...
}
```

This will get the approved users from the group with ID "123". Your user needs to be a member of this group to make this request. Please note that, this API does not take friendship status into account. All other users authorized your channel in the group will be contained in response.

Both the `API.getApproversInFriends` and `API.getApproversInGroup` receive `pageToken` and response in a paginated way. See "Paginated Result" above to check how to use `nextPageToken` to get next page if there it is.