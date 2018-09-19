//
//  NotesViewController.swift
//  NoteTaking
//
//  Created by Siddhi Parekh on 9/14/18.
//  Copyright © 2018 Siddhi Parekh. All rights reserved.
//

// This screen display all the notes in the list view and also allow him to delete all the notes he has created till now.
import UIKit
import CoreData

class NotesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var emptyTableView: UIView!
    var userName = ""
    var notes: [Note] = []
  
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNotes))
        deleteButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = deleteButton
      /*  self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always*/
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = -1
        view.layer.zPosition=0
        if(addBtn.isHidden){
            addBtn.isHidden=false
        }
        addBtn.layer.cornerRadius = 25
        addBtn.translatesAutoresizingMaskIntoConstraints = true
        addBtn.layer.zPosition=1
        getData()
        checkEmptyTableView()
    }
    
    // This function will sets a default view for the notes tableview if there are no records to populate
    func checkEmptyTableView(){
        // Print for debugging
        print("Debugging checkEmptyTableView \(notes.count)")
        notesTableView.reloadData()
        if notes.count==0{
            //Print for debugging
            print(notesTableView.backgroundView)
            print("createEmptyTableView\(notesTableView.numberOfSections)")
            notesTableView.backgroundView = emptyTableView
            //Print for debugging
            print(notesTableView.backgroundView)
            notesTableView.separatorStyle = UITableViewCellSeparatorStyle.none           
        }else {
            notesTableView.backgroundView = nil
           
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
        
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     // performSegue(withIdentifier: "displaydata", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        addBtn.isHidden = true
        if(segue.identifier=="displaydata"){
            
            let displayNoteViewController:DisplayEditViewController = segue.destination as! DisplayEditViewController
            let selectedRow = notesTableView.indexPathForSelectedRow!.row
            // Print for debugging
            print("Debugging prepareforsegue \(selectedRow)")
            displayNoteViewController.note = notes[selectedRow]
            displayNoteViewController.userName = userName
            
        }else if(segue.identifier == "adddata") {
            
            let addNoteViewController:AddNoteViewController = segue.destination as! AddNoteViewController
            // Print for debugging
            print("Debugging prepareforsegue \(userName)")
            addNoteViewController.userName = userName
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        let cell =  notesTableView.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteCell
        cell.setNote(note: note)
        return cell
    }
    
   
    // This function alert the user for permission and delete all the notes
    @objc func deleteNotes(){
       
        if notes.count != 0 {
            createDeleteAllAlert()
            
        } else {
            let alert = UIAlertController(title: "Alert", message: "There are no notes to be deleted.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    
    func createDeleteAllAlert(){
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete all notes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(batchDeleteRequest)
                try context.refreshAllObjects()
                self.notes.removeAll()
                self.checkEmptyTableView()
                //Print for debugging
                print("debugging from createDeleteAllAlert \(self.notes.count)")
            } catch {
                print("something went wrong in deletenotes")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
   
    // This function fetches all the data from the core data - local storage
    func getData(){
          let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
          notes = try context.fetch(Note.fetchRequest())
          // Print for debugging
          print("DebUgging getData \(notes.count)")
        }catch{
            print("something went wrong in getdata")
        }
    }


    
    

   


}

