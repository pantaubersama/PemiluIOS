#  Pantau Bersama

Sebuah gerakan aplikasi gotong royong  © 2018 Pantau Bersama  


## Requirements

XCode 10, iOS 10 SDK or later

## Runtime

iOS 10 or later

### Dependency Management

#### Cocoapods

> https://cocoapods.org

#### Bundler

> http://bundler.io

#### Fastlane

>https://docs.fastlane.tools/getting-started/ios/setup/

Need configure after we have AppStore Account ☺️ 
We hopefully using fastlane to minimize waiting time for uploading App Store, effortless to code signing and more... 

### How to Run

1. git clone 
1. cd PantauBersama
1. bundle install
1. bundle exec pod install
1. open PantauBersama.xcworkspace

### Branch
using `git-flow` approach, to initialize using `git flow init` don't forget to install first 😁

>https://github.com/nvie/gitflow

1. `master` : Release 
1. `develop`: Development branch
1. `feature/`: Adding feature in `develop` branch

### Design Pattern
Absolutely using `MVVM-C` pattern, we hope Pantau Bersama iOS growing bigger 😇🥇 and we're open for member !
Modular strategy for Pantau Bersama version 1.0 :

1. `Common` : One for all modules to define reusable components, reusable library, user defautls, keychain etc...
1. `Networking`: One for all microservices in Pantau. Hopefully we can try networking test here 🏄‍♂️
1. `PantauBersama`: Target files, run `staging` for profile `debug` and `release` for profile `production` 👨🏻‍💻

### Framework
Don't forget to add references framework here after you add some libs in `podfile`

1. RxSwift - https://github.com/ReactiveX/RxSwift
1. RxCocoa - https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa
1. Moya/RxSwift - https://moya.github.io/index.html
1. Crashlytics 
1. Fabric
1. Firebase/Core
1. RxDataSources - https://github.com/RxSwiftCommunity/RxDataSources
1. IQKeyboardManagerSwift -https://cocoapods.org/pods/IQKeyboardManagerSwift


### Some Libs
#### Custom UILabel:  `Label`
Pantau have two styles fonts family like `Lato` and `BWModelica` please contact pantau `designer` if you don't have `assets` font. Little help for creating interfaces from XIB

1. Via XIB
1. Set your custom class with `Label`
1. Feel free to set `Font Size` with your number (default is `12`, i guess :laughing:)
1. Set your `Type Label` with these option (default is `regular`)
You can see in `LabelType` for custom styles in UILabel 

#### Custom UIColor: `Color`
Pantau have many styles for color, see our `zeplin` to match color when you design some `UI`
for example in `Common` we've custom class `Color` such as `primary_red`, `secondary_cyan`, `secondary_orange`, etc. . .
You can use this class to `custom color` for example:

```
swift
let myColor = Color.primary_red
self.view.backgroundColor = myColor
```
In case you want to create your color from RBG, we also give you a little help, here it is
```swift
let color = Color.RGBColor(red: 88, green: 88, blue: 88)
let alphaColor = Color.RGBColor(red: 88, green: 88, blue: 88, alpha: 0.4)
```
Note : I can also misrepresent this whole skeleton, please if you have better understand to build skeleton project don't hesitate to share your knowledge ☺️
