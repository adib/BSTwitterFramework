# Basil Salad Twitter Framework

This library came out from my frustration that the Twitter framework built-in iOS could not access direct messages. As I just found this out in the middle of development of the app (yes, I know I should have plan better in retrospect), this is a real PITA.

Therefore I build this framework with these goals in mind:

- Drop-in replacement to iOS' Twitter Framework.
- Interoperable with iOS's Twitter framework.
- Supports access to direct messages.
- Usable for the Mac (probably in the future).

Yes I've considered Matt Gemmel's MGTwitterEngine but it looks too different than the built-in one and it looks like it haven't been updated for a while. 

This library uses ARC and targeted for iOS 5.x.

## Dependencies

- ASIHTTPRequest - https://github.com/pokeb/asi-http-request.git
- OAuthCore - https://github.com/atebits/OAuthCore

