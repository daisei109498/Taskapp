//
//  inputViewController.swift
//  taskapp
//
//  Created by dslog sys on 2021/07/31.
//

import UIKit
import RealmSwift    // 追加する
import DropDown //ドロップダウンリスト追加

class inputViewController: UIViewController,UIGestureRecognizerDelegate{

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
 
    var task: Task!
    let realm = try! Realm()    // 追加する
        
    let dropDown = DropDown()
    var category = Category()
    var categoryArray = try! Realm().objects(Category.self) // ←追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryLabel.text = task.category?.name
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        let tapAction:UITapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(tapped(_:)))
        categoryLabel?.isUserInteractionEnabled = true
        categoryLabel?.addGestureRecognizer(tapAction)
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            dropDown.show()
        }
    }
    // 追加する
    override func viewWillAppear(_ animated: Bool) {
        categoryArray = try! Realm().objects(Category.self) // ←追加
        //let view = UIView()
        dropDown.anchorView = categoryLabel
        dropDown.dataSource = Array(categoryArray).map { $0.name }
        dropDown.direction = .bottom
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
        categoryLabel.text = item
        }
        super.viewWillAppear(animated)
    }
    
    // 追加する
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            if categoryLabel.text == nil{
                category.name = ""
            } else {
                category.name = categoryLabel.text!
            }
            if category.name != "" {
                categoryArray = try! Realm().objects(Category.self)
               .filter("name == %@", category.name)
                self.task.category = categoryArray[0]
            }
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)   // 追加 ローカル通知
        super.viewWillDisappear(animated)
    }
    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default

        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }

        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    } // --- ここまで追加 ---
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
