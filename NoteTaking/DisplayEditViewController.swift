//
//  DisplayViewController.swift
//  NoteTaking
//
//  Created by Siddhi Parekh on 9/17/18.
//  Copyright © 2018 Siddhi Parekh. All rights reserved.
//
// This screen allows the user to view/edit/delete a note.

import UIKit
import Photos

class DisplayEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    var audioPlayer: AVQueuePlayer? = AVQueuePlayer()
    @IBOutlet weak var playAudio: UIButton!
    let imgPickerController = UIImagePickerController()
    @IBOutlet weak var editVoiceBtn: UIButton!
    var editNoteButton : UIBarButtonItem!
    var deleteNoteButton : UIBarButtonItem!
    var saveNoteButton : UIBarButtonItem!
    @IBOutlet weak var editImgBtn: UIButton!
    @IBOutlet weak var noteUser: UITextField!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var noteTitleView: UITextField!
    var note:Note? = nil
    var navigationBarItems : [UIBarButtonItem] = []
    var imageURL:String = ""
    var audioURL:String = ""
    var userName:String = ""
    var flag:Int = 0
    
    @IBOutlet weak var noteCreatedLabel: UILabel!
    @IBAction func playAudio(_ sender: Any) {
        if(flag==1){
            audioPlayer?.pause()
            audioPlayer = nil
            //playAudio.setTitle("Play", for: .normal)
            playAudio.setImage(UIImage(named: "icons8-circled-play-filled-50"), for: .normal)
            flag=0;
        }
       
        if (audioURL != "") {
            do{
                // let url = Bundle.main.url(forResource: audiofilename, withExtension: "m4a")
               // playAudio.setTitle("Stop", for: .normal)
                if(audioPlayer==nil){
                    audioPlayer = AVQueuePlayer()
                }
                audioPlayer?.removeAllItems()
                print(note?.noteAudioURL)
                var url:URL = URL(string :(audioURL))!
                print(url)
                audioPlayer?.insert(AVPlayerItem(url: url), after: nil)
                audioPlayer?.play()
                playAudio.setImage(UIImage(named: "icons8-pause-button-filled-50"), for: .normal)
                flag=1
            }catch {
                print("Error getting the audio file")
            }
        }else {
            createDefaultAlert(message: "There is no Audio attached to this note.")
        }
        
        
    }

    @IBAction func unwindfromRecordView(_ sender: UIStoryboardSegue) {
        if sender.source is RecordAudioViewController {
            //Print for debugging
            print("Hello from unwind segue - Edit/Delete note")
            let recordAudioViewController  = sender.source as! RecordAudioViewController
            audioURL = recordAudioViewController.audioURL
            //Print for debugging
            print("unwindfromRecordView \(audioURL)")
        }
    }
    
    @IBAction func editImageBtn(_ sender: Any) {
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            imgPickerController.sourceType = .camera
        }
        else{
            imgPickerController.allowsEditing = false
            imgPickerController.sourceType = .photoLibrary
        }
        imgPickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(imgPickerController,animated: true,completion: nil) 
    }
    
    

    func createDefaultAlert(message:String){
        let alert = UIAlertController(title: "My Note", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in   }))
        self.present(alert, animated: true, completion: nil)
    }

    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editImgBtn.isHidden=true
        editVoiceBtn.isHidden=true
        editImgBtn.isEnabled=false
        editVoiceBtn.isEnabled=false
        loadContent()
        
        editNoteButton = UIBarButtonItem()
        editNoteButton.target = self
        editNoteButton.tintColor = UIColor.white
        editNoteButton.action = #selector(editNote)
        editNoteButton.image = UIImage(named:"icons8-edit-32")
        navigationBarItems.append(editNoteButton)
        deleteNoteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        deleteNoteButton.tintColor = UIColor.white
        navigationBarItems.append(deleteNoteButton)
        saveNoteButton = UIBarButtonItem()
        saveNoteButton.target = self
        saveNoteButton.tintColor=UIColor.white
        saveNoteButton.action = #selector(saveEditNote)
        saveNoteButton.image = UIImage(named:"icons8-checkmark-26")
        //navigationBarItems.append(saveNoteButton)
        self.navigationItem.rightBarButtonItems = navigationBarItems
        /*self.navigationController?.navigationBar.prefersLargeTitles = false
         self.navigationController?.navigationItem.largeTitleDisplayMode = .never*/
        // Do any additional setup after loading the view.
    }
    
    func toggleEditFunctions(){
        editImgBtn.isHidden = !editImgBtn.isHidden
        editImgBtn.isEnabled = !editImgBtn.isEnabled
        editVoiceBtn.isHidden = !editVoiceBtn.isHidden
        editVoiceBtn.isEnabled = !editVoiceBtn.isEnabled
    }
    
   
    
    @objc func saveEditNote(){
        //Print for debugging
        print("Debugging from saveEditNote \(imageURL)")
        note?.setValue(noteTitleView.text, forKey: "noteTitle")
        note?.setValue(noteTextView.text, forKey: "noteText")
        note?.setValue(imageURL, forKey: "noteImageURL")
        note?.setValue(audioURL, forKey: "noteAudioURL")
        note?.setValue(Date(), forKey: "noteCreatedDate")
        if(noteUser.text==""){
            note?.setValue(userName, forKey: "noteAuthor")
        }else{
            note?.setValue(noteUser.text, forKey: "noteAuthor")
        }
        navigationBarItems.removeAll()
        navigationBarItems.append(deleteNoteButton)
        navigationBarItems.append(editNoteButton)        
        self.navigationItem.rightBarButtonItems = navigationBarItems
    }
    
    @objc func editNote(){
        toggleEditFunctions()
        noteUser.addBottomBorder(red: 174.0, green: 174.0, blue: 174.0)
        navigationBarItems.removeAll()
        navigationBarItems.append(deleteNoteButton)
        navigationBarItems.append(saveNoteButton)
        self.navigationItem.rightBarButtonItems = navigationBarItems
    }
    
    @objc func deleteNote(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          do {
            try context.delete(note!)
            try context.save()
            clearUI()
            self.navigationController?.popViewController(animated: true)
          }catch{}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recorddatafromedit" {
            let recordAudioViewController = RecordAudioViewController()
            recordAudioViewController.note = note
            recordAudioViewController.flag = false
        }
    }
    
    func clearUI(){
        noteTitleView.text = ""
        noteTextView.text = ""
        noteUser.text = ""
        noteImageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
        
        
    }
    
    func loadImage(url:String){
        if(url == ""){
            self.noteImageView.image = UIImage(named: "defaultimage")
        }else {
            let assetUrl = URL(string: url )!
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [assetUrl], options: nil)
            if let photo = fetchResult.firstObject {
                PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                image, info in
                let myImage = image 
                self.noteImageView.image = myImage }
        }
      }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageURL = ""
        self.noteImageView.image=nil
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageURL = (info[UIImagePickerControllerReferenceURL] as! NSURL).absoluteString!
        //  print(imageurl)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        noteImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

  
    
    func loadContent(){
        //Print for debugging
        print("Debugging from loadContent \(note?.noteTitle)")
        noteTitleView.text = note?.noteTitle
        noteTitleView.addBottomBorder(red: 174.0, green: 174.0, blue: 174.0)
        noteTextView.text = note?.noteText
        noteTextView.layer.borderWidth = 1.0
        noteTextView.layer.cornerRadius = 5
        noteTextView.layer.borderColor = UIColor(red: 174.0, green: 174.0, blue: 174.0, alpha: 1).cgColor
        //Print for debugging
        print("Debugging from loadContent \(note?.noteText)")
        var cDate:String = (note?.noteCreatedDate?.toString(dateFormat: "MM/dd/yy"))!
        //Print for debugging
        print(cDate)
        var user : String = (note?.noteAuthor)!
        let userinfo = "By \(user)"
        noteUser.text=userinfo
        noteUser.addBottomBorder(red: 239.0, green: 239.0, blue: 244.0)
        noteCreatedLabel.text = (note?.noteCreatedDate?.toString(dateFormat: "MM/dd/yy"))!
        imageURL = (note?.noteImageURL)!
        loadImage(url: (note?.noteImageURL!)!)
        //Print for debugging
        print("Debugging from loadContent \(note?.noteAudioURL)")
        audioURL = (note?.noteAudioURL)!
    }
    

    

}



