About Tunes Notifier
--------------
**Website:** http://www.tunes-notifier.com

**Mac App Store:** http://itunes.apple.com/app/tunes-notifier/id555731861?ls=1&mt=12

**Contact:** Jules Coynel (jules@tunes-notifier.com)

Requirements
--------------
Tunes Notifier requires the following
- OS X Mountain Lion (10.8)
- iTunes or Spotify

History
--------------
- **Version 1.3** (Submitted to Apple: 30/12/12 – Released: 08/01/13)
  - Spotify support
  - Reduced processor usage
  
- **Version 1.2** (Submitted to Apple: 30/10/12 – Released: 14/11/12)
  - Japanese language support
  - Spanish language support
  - Danish language support
  - Portuguese language support
  - German language support
  - Turkish language support
  - Clean up all notifications when closing Tunes Notifier
  - Various improvements

- **Version 1.1** (Submitted to Apple: 28/09/12 – Released: 18/10/12)
  - New menu bar icon available in colour and in monochrome
  - Menu icon can be removed temporarily or permanently from menu bar
  - New shortcuts
  - Finnish language support

- **Version 1.0** (Submitted to Apple: 23/08/12 – Released: 25/09/12)
  - Initial version

Code Sign Tunes Notifier for the Mac App Store
--------------
```bash
# Move to Applications folder within Xcode archive
$ cd /Users/Jules/Library/Developer/Xcode/Archives/2012-08-23/Tunes Notifier 23-08-2012 23.16.xcarchive/Products/Applications
 
# Delete the embedded provision profile of the deamon app (Tunes Notifier Helper)
$ rm Tunes\ Notifier.app/Contents/Library/LoginItems/Tunes\ Notifier\ Helper.app/Contents/embedded.provisionprofile
 
# Code sign the deamon
$ codesign -f -s "3rd Party Mac Developer Application: Jules Coynel" -i "com.julescoynel.Tunes-Notifier-Helper" --entitlements "/Users/Jules/Documents/TunesNotifier/Tunes Notifier Helper/Tunes Notifier Helper/Tunes Notifier Helper.entitlements" "Tunes Notifier.app/Contents/Library/LoginItems/Tunes Notifier Helper.app"
 
# Code sign the main application
$ codesign -f -s "3rd Party Mac Developer Application: Jules Coynel" -i "com.julescoynel.Tunes-Notifier" --entitlements "/Users/Jules/Documents/TunesNotifier/Tunes Notifier/Tunes Notifier.entitlements" "Tunes Notifier.app"
 
# "3rd Party Mac Developer Application: Jules Coynel" is the name of the certificate to use as visible in the Keychain Access app
# "com.julescoynel.Tunes-Notifier-Helper" is the bundle identifier of the demon app
# "com.julescoynel.Tunes-Notifier" is the bundle identifier of the main app
```

Documentation
--------------
Tunes Notifier is documented using [appledoc](https://github.com/tomaz/appledoc).

To generate the documentation

- Download appledoc
`git clone git://github.com/tomaz/appledoc.git`
  
- Install it using
`cd /PATH/TO/APPLEDOC/PROJECT` and `sudo sh install-appledoc.sh`
  
- Generate the documentation using
`cd /PATH/TO/TUNES-NOTIFIER/PROJECT` and `appledoc ./`
	
This will create a docset, install it in the default documentation folder for Xcode (`~/Library/Developer/Shared/Documentation/DocSets/`) and make it available within Xcode's Quick Help.

For more information about appledoc please visit http://gentlebytes.com/appledoc/

Licence (MIT)
--------------
Copyright (c) 2012-2013 Jules Coynel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
