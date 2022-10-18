
#打包的环境，正式环境为空，可选 {'mobile';  'desktop';  ''}
APP_ENV="mobile"

#工程名字(Target名字)
Project_Name="${APK_NAME}"

Team_id=###

#配置环境，Release或者Debug
Configuration=Release

#build 路径
project_path="${WORKSPACE}/Client/build/jsb-link/frameworks/runtime-src/proj.ios_mac/${Project_Name}.xcodeproj"
project_scheme="${Project_Name}-${APP_ENV}"
info_path="${WORKSPACE}/Client/build/jsb-link/frameworks/runtime-src/proj.ios_mac/ios/Info.plist"

export_path="${IOS_BUILD_PATH}/${BUILD_TIME}"
export_name="${export_path}/${project_scheme}_${VERSION_NAME}.ipa"

#archive 目标路径
build_dir="${WORKSPACE}/build/ios/archive"
archive_path="${build_dir}/${project_scheme}.xcarchive"

#plist文件
exportOptionsPlist="${build_dir}/ExportOptions.plist"

#签名文件信息
CODE_SIGN_IDENTITY=###
PROVISIONING_PROFILE_SPECIFIER=###
PROVISIONING_PROFILE=###
#AdHoc版本的Bundle ID
PRODUCT_BUNDLE_IDENTIFIER=###

#author Jony
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>destination</key>
	<string>export</string>
	<key>manageAppVersionAndBuildNumber</key>
	<true/>
	<key>method</key>
	<string>app-store</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>'${PRODUCT_BUNDLE_IDENTIFIER}'</key>
		<string>'${PROVISIONING_PROFILE_SPECIFIER}'</string>
	</dict>
	<key>signingCertificate</key>
	<string>Apple Distribution</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>teamID</key>
	<string>'${Team_id}'</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>' > ${exportOptionsPlist}

# 编译
# 证书解锁
security unlock-keychain -p ${###mac用户密码} ${###签名地址]
# 修改版本号
/usr/libexec/Plistbuddy -c "Set CFBundleVersion $VERSION_NAME" "$info_path"
/usr/libexec/Plistbuddy -c "Set CFBundleShortVersionString $VERSION_NAME" "$info_path"
# 清理
xcodebuild clean -project $project_path -scheme $project_scheme -configuration $Configuration
# 构建 archive 包
xcodebuild archive -project $project_path \
    -scheme $project_scheme \
    -configuration $Configuration \
    PLATFORM_NAME=iphoneos \
    -archivePath $archive_path \
    BUILD_DIR="$build_dir"  \
    PROVISIONING_PROFILE_SPECIFIER="${PROVISIONING_PROFILE_SPECIFIER}" \
    PROVISIONING_PROFILE="${PROVISIONING_PROFILE}" \
    PRODUCT_BUNDLE_IDENTIFIER="${PRODUCT_BUNDLE_IDENTIFIER}" -quiet
#输出ipa包
xcodebuild -exportArchive -archivePath $archive_path -exportOptionsPlist $exportOptionsPlist -exportPath $export_path

#上传ipa
xcrun iTMSTransporter -m upload -v informational -assetFile ${export_path}/${project_scheme}.ipa -u ${###apple账号} -p ${###二级密码} 
python3 /Users/yuanyuan/scrpit/end_build_ios_appstore.py $JOB_URL $JOB_NAME $GIT_BRANCH $VERSION_NAME "${SCM_CHANGELOG}"
