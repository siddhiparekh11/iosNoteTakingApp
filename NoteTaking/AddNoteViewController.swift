//
//  DetailViewController.swift
//  NoteTaking
//
//  Created by Siddhi Parekh on 9/15/18.
//  Copyright © 2018 Siddhi Parekh. All rights reserved.
//

//This screen allows the user to add a note. He can add images, text, as well as audio. Speech recognition is also enabled
import UIKit
import Speech


class AddNoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {

    
   
    
    let imgPickerController = UIImagePickerController()
    var notesViewController = NotesViewController()
    var imageURL:String = ""
    var audioURL:String = ""
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var userName: String = ""
    @IBOutlet weak var noteAuthorView: UITextField!
    @IBOutlet weak var noteMessageView: UITextView!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var noteTitleView: UITextField!
    @IBOutlet weak var speechBtnUI: UIButton!
    
    
    @IBAction func speechBtn(_ sender: Any) {
        recordAndRecognizeSpeech()
    }
    
    
    @IBAction func capturePhoto(_ sender: Any) {
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
    
   
    // This is an unwind segue called from RecordAudioViewController
    @IBAction func unwindfromAddNote(_ sender: UIStoryboardSegue) {
        if sender.source is RecordAudioViewController {
            //Print for debugging
            print("Hello from unwind segue - Add Note")
            let recordAudioViewController  = sender.source as! RecordAudioViewController
            audioURL = recordAudioViewController.audioURL
            //Print for debugging
            print("debugging unwindfromAddNote \(audioURL)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordaudiofromadd" {
            let recordAudioViewController = segue.destination as! RecordAudioViewController
            recordAudioViewController.flag = true
        }
    }
    
   
    
    @IBAction func captureAudio(_ sender: Any) {
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        imageURL = ""
        self.noteImageView.image=nil
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageURL = (info[UIImagePickerControllerReferenceURL] as! NSURL).absoluteString!
        //Print for debugging
        print("debugging from imagePickerController \(imageURL)")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.noteImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTitleView.becomeFirstResponder()
        noteTitleView.addBottomBorder(red: 174.0, green: 174.0, blue: 174.0)
        noteAuthorView.text = userName
        noteAuthorView.addBottomBorder(red: 174.0, green: 174.0, blue: 174.0)
        
        noteMessageView.layer.borderWidth = 1.0
        noteMessageView.layer.cornerRadius = 5
        noteMessageView.layer.borderColor = UIColor(red: 174.0, green: 174.0, blue: 174.0, alpha: 1).cgColor
        
        
        // Setting up the navigation bar save/done button
        let saveButton = UIBarButtonItem()
        saveButton.action = #selector(saveNote)
        saveButton.target = self
        saveButton.tintColor = UIColor.white
        saveButton.image = UIImage(named:"icons8-checkmark-26")
        self.navigationItem.rightBarButtonItem = saveButton
        /*self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never*/
        
        //Speech detection is already enabled so disabling the api
        speechBtnUI.isEnabled = false
        speechBtnUI.isHidden = true
      
        
    }
    
    //This function will save the note
    @objc func saveNote(){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let note = Note(context: context)
        
        note.noteText = noteMessageView.text
        if(noteAuthorView.text == ""){
            note.noteAuthor = userName
        }else{
            note.noteAuthor = noteAuthorView.text
        }
        
        note.noteTitle = noteTitleView.text
        note.noteImageURL = imageURL
        note.noteAudioURL = audioURL
        note.noteCreatedDate = Date()
        
        //Print for debugging
        print("debugging from saveNote \(note.noteImageURL)")
        print("debugging from saveNote \(audioURL)")
        
        //Saving the data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        clearUI()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func clearUI(){
        noteTitleView.text = ""
        noteMessageView.text = ""
        noteAuthorView.text = notesViewController.userName
        noteImageView.image = nil
    }
    
    //This function implements speech to text functionality, currently it is disabled
    func recordAndRecognizeSpeech(){
        let node = (audioEngine.inputNode)
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: {buffer, _ in self.request.append(buffer)})
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }catch {
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable {
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.noteMessageView.text = bestString
            }else if let error = error {
                print(error)
            }
            
        })
    }

}
    

