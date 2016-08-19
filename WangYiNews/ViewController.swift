//
//  ViewController.swift
//  WangYiNews
//
//  Created by yb on 16/8/18.
//  Copyright © 2016年 朱德强. All rights reserved.
//

import UIKit

var images = [SKPhoto]();


class ViewController: UIViewController ,UIWebViewDelegate,SKPhotoBrowserDelegate{
    @IBOutlet weak var webView: UIWebView!

        override func viewDidLoad() {
        super.viewDidLoad()
//        http://c.3g.163.com/nc/article/BMU8KHQD00964J4O/full.html
//        http://c.m.163.com/nc/article/BUOAKQT700237VUV/full.html
//        http://c.m.163.com/nc/article/BUCHPIS100963VRO/full.html
        let url = NSURL(string: "http://c.m.163.com/nc/article/BUCHPIS100963VRO/full.html");
        
        let request = NSURLRequest(URL: url!);
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            if(error == nil)
            {
                let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments);
//                print(json);
                self.dealNewsDetail(json as! NSDictionary);
            }
        }
        dataTask.resume();
        
    }
    func dealNewsDetail(json:NSDictionary) -> Void {
//        这里的key BUCHPIS100963VRO，根据上面的url决定
        let alldata = json["BUCHPIS100963VRO"];
        
        var body = alldata!["body"] as! String;
        
        let title = alldata!["title"] as! String;
        
        
        let ptime = alldata!["ptime"] as! String;
        
        let source = alldata!["source"] as! String;
//        [[String : AnyObject]] 数组包含字典
        let img = alldata!["img"] as! [[String : AnyObject]];
        
        for i in 0..<img.count {
            let imgItem = img[i];
            
            let ref = imgItem["ref"] as! String;
            
            let imgTitle = imgItem["alt"] as! String;
            
            let src = imgItem["src"] as! String;
            
            let imgHtml = "<div class=\"all-img\"><img src=\"\(src)\"><div>\(imgTitle)</div></div>";
            
            body = body.stringByReplacingOccurrencesOfString(ref, withString: imgHtml);
            
        }
        
        let titleHtml = "<div id=\"title\">\(title)</div>";
        
        let subTitleHtml = "<div id=\"subTitle\"><span class=\"time\">\(ptime)</span><span class=\"soucre\">\(source)</span></div>"
        
        let css = NSBundle.mainBundle().URLForResource("newsDetail", withExtension: "css");
    
        let cssHtml = "<link href=\"\(css!)\" rel=\"stylesheet\">";
        
        let js = NSBundle.mainBundle().URLForResource("newDetail", withExtension: "js");
        
        let jsHtml = "<script src=\"\(js!)\"></script>";
        
        let html = "<html><head>\(cssHtml)</head><body>\(titleHtml)\(subTitleHtml)\(body)\(jsHtml)</body></html>"
        
        webView.loadHTMLString(html, baseURL: nil);
        
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestStr : String = (request.URL?.absoluteString)!;
//        print(requestStr);
        if ((requestStr.rangeOfString("wy://")) != nil) {
            
            let str = requestStr.substringFromIndex(requestStr.rangeOfString("wy://")!.endIndex);
            let method = str.componentsSeparatedByString("+");
            let sel = NSSelectorFromString(method.first!);
            self.performSelector(sel, withObject: method.last);
            
        }
        return true;
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let getImages = "function getImages(){var imgs = document.getElementsByTagName(\"img\");var allStr = \"\";for(var i = 0;i<imgs.length;i++){var a = imgs[i];allStr =allStr + a.src + \"+\";}return allStr}";
        webView.stringByEvaluatingJavaScriptFromString(getImages);
        let imgs = webView.stringByEvaluatingJavaScriptFromString("getImages()");
        var allImgs = [String]();
        allImgs = (imgs?.componentsSeparatedByString("+"))!;
        allImgs.removeLast();
        for i in 0..<allImgs.count {
            let photo = SKPhoto.photoWithImageURL(allImgs[i]);
            photo.shouldCachePhotoURLImage = true;
            images.append(photo);
        }
    }
    func imageClick(imgUrl : String) -> Void {
        
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(Int(imgUrl)!)
        presentViewController(browser, animated: true, completion: {})
        
    }
}



