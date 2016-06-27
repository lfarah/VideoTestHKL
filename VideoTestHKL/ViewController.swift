//
//  ViewController.swift
//  VideoTestHKL
//
//  Created by Lucas Farah on 6/27/16.
//  Copyright © 2016 Lucas Farah. All rights reserved.
//

import UIKit
import Track
import EZSwiftExtensions


class ViewController: UIViewController {

	@IBOutlet weak var table: UITableView!
	let track = Cache.shareInstance
	let loginController = LFLoginController()

	let videos = ["https://s3-sa-east-1.amazonaws.com/hkl/HKL+Interactive+Media.mp4", "https://s3-sa-east-1.amazonaws.com/hkl/separacao.mp4", "https://s3-sa-east-1.amazonaws.com/hkl/Pao+e+Leite.mp4"]
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

        loginController.delegate = self
        loginController.loginButtonColor = UIColor(hexString: "f8c300")
        loginController.logo = UIImage(named: "logo-hkl")
		self.navigationController?.pushViewController(loginController, animated: true)
	}

	func play(path: String) {

		var model = SSVideoModel()
		if isCached(path) {
			let name = getNameForURL(path)
			let filePath = self.documentsPathForFileName("\(name).mp4")
			let videoData = track.object(forKey: name) as! NSData
			videoData.writeToFile(filePath, atomically: true)
			let videoFileURL = NSURL(fileURLWithPath: filePath)

			model = SSVideoModel(name: "teste", path: videoFileURL.path)

		} else {
			model = SSVideoModel(name: "teste", path: path)
		}

		let playController = SSVideoPlayController(videoList: [model])
		let playContainer = SSVideoPlayContainer(rootViewController: playController)
		self.presentViewController(playContainer, animated: true, completion: nil)
		cacheVideo(path)

	}

	func documentsPathForFileName(name: String) -> String {

		let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
		return documentsPath.stringByAppendingString(name)
	}
	func isCached(url: String) -> Bool {

		if let _ = track.object(forKey: getNameForURL(url)) {

			return true
		} else {
			return false
		}
	}

	func getNameForURL(url: String) -> String {

		var videoStr = ""
		for video in videos {
			if url == video {

				videoStr = "video\(videos.indexOf(video))"
			}
		}
		return videoStr
	}

	func cacheVideo(path: String) {

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			let url = NSURL(string: path)
			let urlData = NSData(contentsOfURL: url!)
			if urlData != nil {

				self.track.set(object: urlData!, forKey: self.getNameForURL(path))
				print("CACHED")
			}
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

extension ViewController: UITableViewDataSource {

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell!
		if !(cell != nil) {
			cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
		}

		// setup cell without force unwrapping it
		cell.textLabel!.text = "Video \(indexPath.row + 1)"
		return cell
	}
}

extension ViewController: UITableViewDelegate {

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		let path = videos[indexPath.row]
		play(path)
	}
}

extension ViewController: LFLoginControllerDelegate {

	func loginDidFinish(email: String, password: String, type: LFLoginController.SendType) {

        self.navigationController?.setNavigationBarHidden(false, animated: true)
		self.navigationController?.popViewControllerAnimated(true)
	}

	func forgotPasswordTapped() {

		print("forgot password")
	}

}

