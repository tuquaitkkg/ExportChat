//
//  ChatViewController.swift
//  ExportChats
//
//  Created by ToanNT on 1/31/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import SSZipArchive
import JSQMessagesViewController
import AVKit
import MessageKit

class ChatViewController: MessagesViewController, UITextFieldDelegate {
    var conversationInfo : [String : String]!
    var messages = [MockMessage]()
    var chats = [ChatObj]()
    var senderID = ""
    var rootPath = ""
    var senderPerson : Sender!
    var rootPerson : String!
    var listImage = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //init list image
        for i in 0..<10 {
            self.listImage.append(UIImage(named: "bg\(i)")!)
        }
        title = conversationInfo["name"]
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.isHidden = true
        
        senderPerson = Sender(id: conversationInfo["name"]!, displayName: conversationInfo["name"]!)
        navigationController?.navigationBar.isHidden = false
    }
    
    func setUp() {
        messages = [MockMessage]()
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0]
        rootPath = documentsDirectory
        if let cInfo = conversationInfo , let path = conversationInfo["path"] {
            let urlFolderUnzip = URL.init(string: documentsDirectory.appending(path))
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: urlFolderUnzip!, includingPropertiesForKeys: nil)
                if fileURLs.count > 0 {
                    for urlFile in fileURLs {
                        if urlFile.lastPathComponent == "_chat.txt" {
                            do {
                                let stringContent = try String.init(contentsOfFile: urlFile.path)
                                print(stringContent)
                                let sentenceArr = stringContent.components(separatedBy: "\n")
                                let sentenceObj = CommonUtils().conversationWithArrayChat(sentenceArr, andPathFile: cInfo["path"]!)
                                print(sentenceObj.chats as Any)
                                if let chat = sentenceObj.chats {
                                    chats = chat
                                    rootPerson = sentenceObj.personName
                                    initialChat()
                                    
                                }
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func initialChat() {
        if chats.count > 0 {
            for item in chats {
                var idSender : Sender
                if item.chatOwner == rootPerson {
                    idSender = senderPerson
                } else {
                    idSender = currentSender()
                }
                if item.filePath != ""{
                    let string = item.filePath?.replacingOccurrences(of: "\r", with: "")
                    let host = rootPath
                    if var string = string {
                        string = host.appending(string)
                        let url = URL.init(string: string)
                        addMediaMessage(withId: idSender, name: item.chatOwner, mediaURL: url!, times: item.time, item: item)
                    }
                } else {
                    addMessage(withId: idSender, name: item.chatOwner, text: item.text, time: item.time)
                }
            }
            setRandomBackground()
            messagesCollectionView.reloadData()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        setUp()
    }

    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func setRandomBackground() {
        if listImage.count > 0 {
            let index = randomInt(min: 0, max: listImage.count-1)
            let image = listImage[index]
            let imageView = UIImageView(frame: self.view.frame)
            imageView.image = image
            self.view.addSubview(imageView)
            self.view.sendSubview(toBack: imageView)
            self.messagesCollectionView.backgroundColor = UIColor.clear
        }
    }
    
    //Add message
    private func addMessage(withId id: Sender, name: String, text: String, time: Date) {
        let ntext = text.replacingOccurrences(of: "\r", with: "")
        let message = MockMessage(text: ntext, sender: id, messageId: id.id, date: time)
        messages.append(message)
    }
    
    private func addMediaMessage(withId id: Sender, name: String, mediaURL: URL, times : Date, item: ChatObj) {
        let mediaPath = mediaURL.absoluteString as NSString
        if mediaPath.pathExtension.contains("mp4") {
            let index = chats.index(of: item)
            DispatchQueue.global().async {
                let url = URL.init(fileURLWithPath: mediaPath as String)
                let asset = AVAsset(url: url)
                let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                assetImgGenerate.appliesPreferredTrackTransform = true
                let time = CMTimeMake(1, 2)
                let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                if img != nil {
                    let frameImg  = UIImage(cgImage: img!)
                    DispatchQueue.main.async(execute: {
                        let message = MockMessage(thumbnail: frameImg, sender: id, messageId: id.id, date: times, url: url)
                        self.messages.insert(message, at: index!)
                        self.messagesCollectionView.reloadData()
                    })
                }
            }
        } else if mediaPath.pathExtension.contains("jpg")  {
            let image = UIImage(contentsOfFile: mediaPath as String)!
//            listImage.append(image)
            let message = MockMessage(image: image, sender: id, messageId: id.id, date: times)
            messages.append(message)
        } else {
            let indexItem = chats.index(of: item)
            chats.remove(at: indexItem!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChatViewController : MessagesDataSource {
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: senderID, displayName: "me")
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Cell tapped")
        let index = messagesCollectionView.indexPath(for: cell)
        let chat = chats[(index?.section)!]
        if let filePath = chat.filePath {
            if filePath.contains("mp4") {
                if var path = chat.filePath {
                    path = path.replacingOccurrences(of: "\r", with: "")
                    path = rootPath.appending(path)
                    let url = URL.init(fileURLWithPath: path)
                    let player = AVPlayer(url: url)
                    let playerViewController = AVPlayerViewController()
                    //                    let audioSession = AVAudioSession.init()
                    
                    playerViewController.player = player
                    present(playerViewController, animated: true) { () -> Void in
                        player.volume = 1
                        player.play()
                    }
                }
            }
        }
    }
    
}
// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor.jsq_messageBubbleBlue()
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func heightForMedia(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 250
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func avatarPosition(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarPosition {
        return AvatarPosition(horizontal: .natural, vertical: .messageBottom)
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 60)
        }
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        } else {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        } else {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }
    
    // MARK: - Location Messages
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize.zero
    }
}
