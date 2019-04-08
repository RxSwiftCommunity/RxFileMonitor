# RxFileMonitor

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![macOS Compatible](https://img.shields.io/badge/platform-macos-lightgrey.svg)

RxSwift `Observable` wrapper for CoreFoundation file system events.

The example app can serve as an always-on-top floating file event log. Launch the app, select a directory, select _Window > Always On Top_, and enjoy the events pouring in. You can also <kbd>⌘K</kbd> clear logged messages.

## Usage

You set up a `FolderContentMonitor` on a folder and will be notified about ...

- changes to the folder itself, and
- changes to any item inside it (not including sub-folders).

It exposes a reactive extension via `.rx.folderContentChange` for your convenience.

Example:

```swift
import RxFileMonitor

let disposeBag = DisposeBag()
let folderUrl = URL(fileURLWithPath: "/path/to/monitor/")

// Keep this strongly referenced/alive
let monitor = FolderContentMonitor(url: folderUrl)

monitor.rx.folderContentChange
    .subscribe(onNext: { event in
        print("Folder contents changed at \(event.url) (\(event.change))")
    })
    .disposed(by: disposeBag)
```

### Reacting to file content changes only

Say you want to update a cache of a folder's notes' contents, you'll be interested in files only:

```swift
self.monitor = FolderContentMonitor(url: folderUrl)
let changedFile = self.monitor.rx.folderContentChange
    // Files only ...
    .filter { $0.change.contains(.isFile) }
    // ... except the user's folder settings.
    .filter { $0.filename != ".DS_Store" }
    .map { $0.filename }
    .observeOn(MainScheduler.instance)
    .disposed(by: disposeBag)
```

Now you will want to update the cache for the changed file:

```swift
changedFile.subscribe(onNext: cache.updateFile)
```

Or if you simply rebuild the whole cache when anything changed, you can stop after filtering for accepted events:

```swift
// Keep this strongly references
self.monitor = FolderContentMonitor(url: folderUrl)
let changedFile = self.monitor.rx.folderContentChange
    .filter { $0.change.contains(.isFile) }
    .filter { $0.filename != ".DS_Store" }
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { _ in 
        cache.rebuild()
    })
```

## A Note on Latency

A latency of 0.0 (default value) can produce too much noise. Experiment with slightly higher values so the system can coalesce events when appropriate.

When you run the example app to see which kinds of events are fired, make sure to use TextEdit to create and modify a file so you see what kinds of events are bound to happen. Here's an annotated log:

```
// Create file in folder

texteditfile.txt changed (isFile, renamed, xattrsModified)
texteditfile.txt changed (isFile, renamed, finderInfoModified, xattrsModified)


// Save changes to file

texteditfile.txt changed (isFile, renamed, finderInfoModified, xattrsModified)
texteditfile.txt.sb-56afa5c6-DmdqsL changed (isFile, renamed)
texteditfile.txt changed (isFile, renamed, finderInfoModified, xattrsModified)
texteditfile.txt changed (isFile, renamed, finderInfoModified, inodeMetaModified, xattrsModified)
texteditfile.txt.sb-56afa5c6-DmdqsL changed (isFile, modified, removed, renamed, changeOwner)
texteditfile.txt changed (isFile, renamed, finderInfoModified, inodeMetaModified, xattrsModified)
```

You see that overwriting a file _atomically_ will fire a lot of events when you use a modern document-based macOS app like TextEdit. The authors interpretation of these events is: "get rid of the original file, move in temp file with changes, copy temp file to original file's path, then get rid of the temp file". It could mean the original file is renamed to the temporary looking name just as well as far as I know. (Which, apparently, isn't much.)

Now see the log for the same actions with a latency of 1 second:

```
// Create file in folder

texteditfile.txt changed (isFile, renamed, finderInfoModified, xattrsModified)

// Save changes to file

texteditfile.txt changed (isFile, renamed, finderInfoModified, xattrsModified)
texteditfile.txt.sb-56afa5c6-SOiDRl changed (isFile, renamed)
texteditfile.txt changed (isFile, renamed, finderInfoModified, inodeMetaModified, xattrsModified)
texteditfile.txt.sb-56afa5c6-SOiDRl changed (isFile, modified, removed, renamed, changeOwner)
```

(Doesn't get any better than this.)

So maybe a latency of slightly above >0.0 can help get rid of noise. Makes even more sense when you coalesce the `RxSwift.Observable` events in the end.

Note that other editors like TextMate 2 don't write to files with the same mechanism and only generate a single event, similar to what you'd expect from file changes originating in the shell:

```
texteditfile.txt changed (isFile, modified, xattrsModified)
```


## Event Interpretation

Look at the repository's issues -- there's still a lot of room for improvement. This boils down to applying _interpretation_ and _heuristics_. In other words, it might break or be utterly wrong.

At the moment, each and every FSEvent is forwarded to the callback (or observer).

But FSEvents sometimes come in pairs, like:

```
texteditfile.txt changed (isFile, renamed, finderInfoModified, xattrsModified)
texteditfile.txt.sb-56afa5c6-SOiDRl changed (isFile, renamed)
```

That means the library could try to make sense of event pairs and reduce them to single events for the client. Instead of forwarding an event of the form "`texteditfile.txt.sb-56afa5c6-SOiDRl` was renamed" which, in client's terms, will be interpreted as "the file was moved in there", the library could fire a single "edited" event.

Also noteworthy: the `removed` event will not be fired when trashing a file from Finder even though it was fired when TextEdit saved file changes and got rid of the intermediate result file. Some `renamed` events thus really are `removed` events and you need to check the file at the URL for existence after the event comes in. With a certain latency, or else you may pick up the about-to-be-trashed file _before_ its being moved is completed. 


## License

Copyright (c) 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity

Distributed under The MIT License:

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
