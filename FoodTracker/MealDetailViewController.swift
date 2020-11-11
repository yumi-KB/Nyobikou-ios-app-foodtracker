//
//  ViewController.swift
//  FoodTracker
//
//  Created by yumi kanebayashi on 2020/10/15.
//

import UIKit
import os.log

class MealDetailViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        updateSaveButtonState()
    }
    
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        // true ならモーダル　falseならプッシュ表示
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode{
            // モーダルを閉じるメソッド
            dismiss(animated: true, completion: nil)
        } else if let owingNavigationController = navigationController {
            owingNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealDetailViewController is not inside a navigation controller.")
        }
    }
    // prepareメソッド　遷移前の準備　条件分岐
    // This method lets you comfigure a view controller before it is presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Save or Cancell is return
        // ボタンが押された　saveなら　cancellなら ===は同一オブジェクトか？　==はequalか？
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating)
        // destinationから　sender.source.mealでアクセスする
    }
    
    
    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        // 直前にキーボードを開いてテキストフィールドを編集中だった場合、隠す
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        // .photoLibraryは、UIimagePickerControllersourceType.photoLibrary
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        // self(MealDetailViewController)を、画像選択完了時の通知先として設定する
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
}

//　MARK: UITextFieldDelegate
extension MealDetailViewController: UISearchTextFieldDelegate {
    // First Responderを解除するタイミングを決める
    // リターンキー(Done)を押した際に起動する関数
    // キーボードを収納し、リターンキーを完了させる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        // Bool型なので
        return true
    }
    
    // First Responder が解除された後(キーボードが閉じた後・編集終了時)に動作する関数
    // 入力値をLabelに反映
    func textFieldDidEndEditing(_ textField: UITextField) {
        mealNameLabel.text = textField.text
        
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    // キーボードが出現した時（編集開始時）に動作する関数
    // 編集中はsaveButtonを押せないようにする
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

// MARK: UIImagePickerControllerDelegate+UINavigationControllerDelegate
extension MealDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provide the following: \(info)")
        }

        // photoImageViewに反映
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}


