# RxFileMonitor

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

RxSwift `Observable` wrapper for CoreFoundation file system events.

## Usage

The most convenient usage is through the RxSwift `Observable` exposed in the module as:

```swift
Monitoring.folderMonitor(url: URL) -> Observable<FolderContentChangeEvent>
```

You use it on a folder and will be notified about ...

- changes to the folder itself, and
- changes to any item inside it (not including sub-folders).

Example:

```swift
import RxFileMonitor

let disposeBag = DisposeBag()
let folderUrl = URL(fileURLWithPath: "/path/to/monitor/")

Monitoring.folderMonitor(url: folderUrl)
    .subscribe(onNext: { event in
        print("Folder contents changed at \(event.url) (\(event.change))")
    })
    .addDisposableTo(disposeBag)
```

### Reacting to file content changes only

Say you want to update a cache of a folder's notes' contents, you'll be interested in files only:

```swift
let changedFile = Monitoring.folderMonitor(url: folderUrl)
    // Files only ...
    .filter { $0.change.contains(.isFile) }
    // ... except the Spotlight cache.
    .filter { $0.filename != ".DS_Store" }
    .map { $0.filename }
    .observeOn(MainScheduler.instance)
```

Now you will want to update the cache for the changed file:

```swift
changedFile.subscribe(onNext: cache.updateFile)
```

Or if you simply rebuild the whole cache when anything changed, you can stop after filtering for accepted events:

```swift
let changedFile = Monitoring.folderMonitor(url: folderUrl)
    .filter { $0.change.contains(.isFile) }
    .filter { $0.filename != ".DS_Store" }
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { _ in 
        cache.rebuild()
    })
```

## License

Copyright (c) 2016 Christian Tietze.

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
