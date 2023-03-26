//
//  ViewController.swift
//  Jaguar2
//
//  Created by Paolo Piccini on 25/03/23.
//

import UIKit
import WebKit
import PDFKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
  
  var viewModel = MainViewModel()

  private lazy var webView: WKWebView = {
    let view = WKWebView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.scrollView.isScrollEnabled = false
    view.scrollView.bounces = false
    view.navigationDelegate = self
    return view
  }()

  private lazy var pdfView: WKWebView = {
    let view = WKWebView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.scrollView.isScrollEnabled = true
    view.scrollView.bounces = true
    return view
  }()

  private lazy var closeButton: UIButton = {
    let view = UIButton(type: .system)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
    view.tintColor = .black
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
    setupBindings()
  }

  override func viewDidLayoutSubviews() {
    viewModel.loadEDetail()
  }

  private func setupUI() {
    navigationController?.isNavigationBarHidden = true
    view.addSubview(webView)
    view.addSubview(pdfView)
    pdfView.addSubview(closeButton)
    view.sendSubviewToBack(pdfView)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([

      pdfView.topAnchor.constraint(equalTo: view.topAnchor),
      pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      closeButton.topAnchor.constraint(equalTo: pdfView.topAnchor, constant: 40),
      pdfView.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 40),

      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }

  private func setupBindings() {

    closeButton.rx.tap
      .subscribe(onNext: { [unowned self] _ in
        view.sendSubviewToBack(pdfView)
      })
      .disposed(by: viewModel.bag)

    viewModel.pdfRequestSubject
      .filter { $0 != nil }
      .compactMap { $0 }
      .subscribe(onNext: { [unowned self] request in
        view.sendSubviewToBack(webView)
        pdfView.load(request)
      })
      .disposed(by: viewModel.bag)

    viewModel.urlRequestSubject
      .filter { $0 != nil }
      .compactMap { $0 }
      .subscribe(onNext: { [unowned self] request in
        webView.load(request)
      })
      .disposed(by: viewModel.bag)
  }

}

extension MainViewController: WKNavigationDelegate {

  public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

    defer {
      decisionHandler(.allow)
    }

    guard let url = navigationAction.request.url else { return }

    let myCustomProtocol = url.absoluteString.components(separatedBy: "://").first

    if (myCustomProtocol == "pdf") {
      let myPDF = url.absoluteString.components(separatedBy: "//")[1]
      let documentToDisplay = ContentModel(id: myPDF, icon: "", type: "pdf")

      guard let filePath = Bundle.main.path(forResource: "archivio/contents/" + documentToDisplay.id, ofType: documentToDisplay.type) else { return }
      let fileURL = URL(fileURLWithPath: filePath)
      viewModel.pdfRequestSubject.onNext(URLRequest(url: fileURL))

    } else if (myCustomProtocol == "reloadexternalcontents") {
      let myXMLName:String = (url.absoluteString.components(separatedBy: "//")[1])
      viewModel.loadExternalContents(myXMLName)
    }
  }

}
