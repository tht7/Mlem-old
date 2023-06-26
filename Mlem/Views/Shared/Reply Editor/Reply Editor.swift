//
//  Reply Editor.swift
//  Mlem
//
//  Created by David Bureš on 20.05.2023.
//

import SwiftUI

#if os(macOS)
struct ReplyEditor: NSViewRepresentable
{
    
    @Binding var text: String

    func makeNSView(context: Context) -> NSTextView
    {
        let textField = NSTextView()

        textField.font = .systemFont(ofSize: 15)

        textField.becomeFirstResponder()

        textField.delegate = context.coordinator

        return textField
    }

    func updateNSView(_ textField: NSTextView, context _: Context)
    {
        textField.string = text
    }

    func makeCoordinator() -> Coordinator
    {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, NSTextViewDelegate
    {
        @Binding var text: String

        init(text: Binding<String>)
        {
            _text = text
        }

        func textViewDidChange(_ textView: NSTextView)
        {
//            if let selectedRange = textView.selectedRanges.first
//            {
//                let cursorPosition = textView.offaut //.offset(from: 0, to: selectedRange)
//                print("Cursor position: \(cursorPosition)")
//            }
//            
            text = textView.string
        }
        
    }

    typealias NSViewType = NSTextView
}
#else
struct ReplyEditor: UIViewRepresentable
{
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView
    {
        let textField = UITextView()

        textField.font = .systemFont(ofSize: 15)

        textField.becomeFirstResponder()

        textField.delegate = context.coordinator

        return textField
    }

    func updateUIView(_ textField: UITextView, context _: Context)
    {
        textField.text = text
    }

    func makeCoordinator() -> Coordinator
    {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextViewDelegate
    {
        @Binding var text: String

        init(text: Binding<String>)
        {
            _text = text
        }

        func textViewDidChange(_ textView: UITextView)
        {
            if let selectedRange = textView.selectedTextRange
            {
                let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                print("Cursor position: \(cursorPosition)")
            }
            
            text = textView.text
        }
        
    }

    typealias UIViewType = UITextView
}
#endif
