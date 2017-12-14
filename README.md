[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub release](https://img.shields.io/github/release/Comcast/mamba.svg)](https://github.com/Comcast/mamba/releases)
[![License](https://img.shields.io/cocoapods/l/Mamba.svg)](https://raw.githubusercontent.com/Comcast/mamba/master/LICENSE.md)
[![Platform](https://img.shields.io/cocoapods/p/Mamba.svg?style=flat)]()

Mamba
===

Mamba is a Swift iOS and tvOS framework to parse, validate and write [HTTP Live Streaming (HLS)](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23) data.

This framework is used in Comcast applications to parse, validate, edit and write HLS manifests to deliver video to millions of customers. It was written by the [Comcast VIPER](https://stackoverflow.com/jobs/companies/comcast-viper) Player Platform team.

_Mamba Project Goals:_

* **Simple-to-use parsing, editing and writing** of HLS manifests.

* **Maximum performance**. We required our parsing library to parse very large HLS manifests (12 hour Video-On-Demand) on low end phones in a few milliseconds. A internal core C library is used for very fast parsing of large manifests.

## Usage

### _Parsing a HLS Manifest_

Create an `HLSParser`. 

```swift
let parser = HLSParser()
```

Parse your HLS manifest using the parser. Here's the callback version:

```swift
let myManifestData: Data = ... // source of HLS data
let myManifestURL: URL = ... // the URL of this manifest resource

parser.parse(manifestData: myManifestData,
	         url: myManifestURL,
	         success: { manifest in
	              // do something with the parsed HLSManifest object
	         },
	         failure: { parserError in
	              // handle the HLSParserError
	         })
```

And here's the inline version:

```swift
let manifest: HLSManifest
do {
    // note: could take several milliseconds for large manifests!
    manifest = try parser.parse(manifestData: myManifestData,
                                url: myManifestURL)
}
catch {
	// we received an error in parsing this manifest
}
// do something with the parsed HLSManifest
```

You now have an HLS manifest object.

### _HLSManifest_

This struct is a in-memory representation of a HLS manifest.

It includes:

* The `URL` of the manifest.
* An array of `HLSTag`s that represent each line in the HLS manifest. This array is editable, so you can make edits to the manifest.
* Utility functions to tell if a manifest is a master or variant, and if it is a Live, VOD or Event style playlist.
* Helpful functionality around the structure of a manifest, including calculated references to the "header", "footer" and all the video fragments and the metadata around them. This structure is kept up to date behind the scenes as the manifest is edited.

`HLSManifest` objects are highly editable.

### _Validating a HLS Manifest_

Validate your HLS Manifest using the `HLSCompleteManifestValidator`.

```swift
let issues = try HLSCompleteManifestValidator.validate(hlsManifest: manifest)
```

It returns an array of `HLSValidationIssue`s found with the HLS Manifest. They each have a description and a severity associated with them.

*We currently implement only a subset of the HLS validation rules as described in the [HLS specification](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23). Improving our HLS validation coverage would be a most welcome pull request!*

### _Writing a HLS Manifest_

Create a `HLSWriter`.

```swift
let writer = HLSWriter()
```

Write your HLS manifest to a stream.

```swift
let stream: OutputStream = ... // stream to receive the HLS Manifest

do {
	try writer.write(hlsManifest: manifest, toStream: stream)
}
catch {
	// there was an error severe enough for us to stop writing the data
}
``` 

### _Using Custom Tags_

Natively, Mamba only understands HLS tags as defined in the [Pantos IETF specification](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23). If you'd like to add support for a custom set of tags, you'll need to create them as a object implementing `HLSTagDescriptor`. Please look at `PantosTag` or one of the examples in the unit tests for sample code.

If you have any custom `HLSTagDescriptor` collections you'd like to parse alongside the standard Pantos tags, pass them in through this HLSParser initializer:

```swift
enum MyCustomTagSet: String {
    // define your custom tags here
    case EXT_MY_CUSTOM_TAG = "EXT-MY-CUSTOM-TAG"
}

extension MyCustomTagSet: HLSTagDescriptor {
    ... // conform to HLSTagDescriptor here
}

let customParser = HLSParser(tagTypes: [MyCustomTagSet.self])
```

If there is specfic data inside your custom tag that you'd like to access, e.g.

```
#EXT-MY-CUSTOM-TAG:CUSTOMDATA1="Data1",CUSTOMDATA2="Data1"
```

you can define that data in an enum that conforms to `HLSTagValueIdentifier`:

```swift
enum MyCustomValueIdentifiers: String {
    // define your custom value identifiers here
    case CUSTOMDATA1 = "CUSTOMDATA1"
    case CUSTOMDATA2 = "CUSTOMDATA2"
}

extension MyCustomValueIdentifiers: HLSTagValueIdentifier {
    ... // conform to HLSTagValueIdentifier here
}
```

You can now look through `HLSTag` objects for your custom tag values just as if it were a valuetype defined in the HLS specification.

### _Important Note About Memory Safety_

In order to achieve our performance goals, the internal C parser for HLS had to minimize the amount of heap memory allocated.

This meant that, for each `HLSTag` object that is included in a `HLSManifest`, instead of using a swift `String` to represent data, we use a `HLSStringRef`, which is a object that is a reference into the memory of the original data used to parse the manifest. This greatly speeds parsing, but comes at a cost: **these `HLSTag` objects are unsafe to use beyond the lifetime of their parent `HLSManifest`**. 

In general, this is no problem. Normal usage of a `HLSManifest` would be (1) Parse the manifest, (2) Edit by manipulating `HLSTag`s (3) Write the manifest. 

If you do, for some reason, need to access `HLSTag` data beyond the lifetime of the parent `HLSManifest` object, you'll need to make a copy of all `HLSStringRef` data of interest into a regular swift `String`. There's a string conversion function in `HLSStringRef` to accomplish this.

### _Nomenclature_

This project and its documentation use the words "fragment" and "segment" and also the words "manifest" and "playlist" interchangably. See the [HLS specification](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23) for more details about segment and playlist definitions.