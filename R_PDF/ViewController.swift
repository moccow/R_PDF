//
//  ViewController.swift
//  
//  
//  Created by m.ishiyama on 2023/08/25
//  
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    var currentPageIndex = 0
    var pageCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pdfView.delegate = self
        let fileName = "pdf-link-annotation-sample"
        if let pdfURL = Bundle.main.url(forResource: fileName, withExtension: "pdf"),
            let pdfDocument = PDFDocument(url: pdfURL) {
            pageCount = pdfDocument.pageCount
            print("===========pageCount \(pdfDocument.pageCount)")
            pdfView.document = pdfDocument
            pdfView.autoScales = true
            pdfView.displayDirection = .horizontal
            pdfView.displayMode = .singlePage
            pdfView.displaysPageBreaks = false
            // MARK: これを使用すればキレイにスワイプによるページ移動が可能だが、ワーニングが出る
            // pdfView.usePageViewController(true)
            pdfView.go(to: pdfDocument.page(at: currentPageIndex)!)
//            pdfView.displayBox = .cropBox
        }
        
        // MARK: usePageViewControllerを使用せずにスワイプを管理
        // MARK: この方法だとスワイプ中のページを引っ張る動作は実現できない。
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        leftSwipeGesture.direction = .left // 左にスワイプした場合の例
        pdfView.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        rightSwipeGesture.direction = .right // 左にスワイプした場合の例
        pdfView.addGestureRecognizer(rightSwipeGesture)

    }
    
    // MARK: usePageViewControllerを使用せずにスワイプを管理
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // 左にスワイプした場合の処理
            if currentPageIndex < pageCount - 1 {
                let targetPageIndex = currentPageIndex + 1
                animatePageTransition(to: targetPageIndex)
            }
        } else if gesture.direction == .right {
            // 右にスワイプした場合の処理
            if currentPageIndex > 0 {
                let targetPageIndex = currentPageIndex - 1
                animatePageTransition(to: targetPageIndex)
            }
        }
    }
    
    @IBAction func lefButtonTapped(_ sender: UIButton) {
        let currentPageNumber = pdfView.currentPage?.pageRef?.pageNumber ?? 0
        print("========= currentPageNumber: \(currentPageNumber)")
        guard currentPageNumber > 1 else { return }
        currentPageIndex = currentPageNumber - 1
        animatePageTransition(to: currentPageIndex - 1)
    }
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        let currentPageNumber = pdfView.currentPage?.pageRef?.pageNumber ?? 0
        print("========= currentPageNumber: \(currentPageNumber)")
        guard currentPageNumber < pageCount else { return }
        currentPageIndex = currentPageNumber - 1
        animatePageTransition(to: currentPageIndex + 1)
    }

    
    private func animatePageTransition(to pageIndex: Int) {
        print("animatePageTransition")
        // スライドインアニメーションの実装
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = .push
        if pageIndex > currentPageIndex {
            transition.subtype = .fromRight
        } else {
            transition.subtype = .fromLeft
        }
        pdfView.layer.add(transition, forKey: nil)
        
        // ページを切り替える
        pdfView.go(to: (pdfView.document?.page(at: pageIndex))!)
        
        currentPageIndex = pageIndex
    }
}

extension ViewController: PDFViewDelegate {
    // PDFViewDelegate method
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        // リンクがクリックされた際の処理
        print("tap")
    }
//    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
//        if let action = pdfView.currentSelection?.destination?.action as? PDFActionGoTo {
//            let pageIndex = action.destination.pageIndex
//            pdfView.go(to: pdfView.document!.page(at: pageIndex)!)
//        }
//    }
}
