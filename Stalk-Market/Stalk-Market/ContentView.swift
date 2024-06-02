//
//  ContentView.swift
//  Stalk-Market
//
//  Created by Thanushan Pirapakaran on 2024-05-27.
//

import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    @StateObject private var keyboardResponder = KeyboardResponder()
    @State var searchRes: String = ""
    @State var tickerList: SearchAPIRes = SearchAPIRes(quotes: [])
    var body: some View {
        NavigationView{
            ZStack {
                Image("Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.3)
                VStack{
                    HStack{
                        Text("Stalk-Market")
                            .font(.custom("AmericanTypewriter", size: 40))
                            .fontWeight(.semibold)
                            .padding()
                    }
                    ScrollView {
                        ForEach(tickerList.quotes) { quote in
                            SearchResult(ticker: quote.symbol)
                        }
                    }
                    .scrollIndicators(/*@START_MENU_TOKEN@*/.hidden/*@END_MENU_TOKEN@*/, axes: /*@START_MENU_TOKEN@*/[.vertical, .horizontal]/*@END_MENU_TOKEN@*/)
                    
                    Spacer()
                    PaddedTextField(text: $searchRes, tickerList: $tickerList, placeholder: "Search")
                        .offset(y: -keyboardResponder.currentHeight / 2)
                }
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Gradient(colors: [
                Color(UIColor(named: "lightPurple")!), Color(UIColor(named: "darkPurple")!), Color(UIColor(named: "darkPurple")!)]).opacity(0.6))
        }
        
    }
}
struct PaddedTextField: View {
    @Binding var text: String
    @Binding var tickerList: SearchAPIRes
    var placeholder: String
    var body: some View {
        HStack {
            TextField(placeholder, text: $text){
                getSearchResults()
            }
                .autocapitalization(.allCharacters)
                .padding(10)
                .font(.title)
        }
        .background()
        .cornerRadius(20.0)
        .padding()
        .lineLimit(1)
    }
    func getSearchResults(){
        if let key = ProcessInfo.processInfo.environment["YahooAPI2"]{
            let headers = [
                "X-RapidAPI-Key": key,
                "X-RapidAPI-Host": "yahoo-finance127.p.rapidapi.com"
            ]
            let request = NSMutableURLRequest(url: NSURL(string: "https://yahoo-finance127.p.rapidapi.com/search/"+text)! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error as Any)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse!)
                    
                    tickerList = try! JSONDecoder().decode(SearchAPIRes.self, from: data!)
                }
            })
            //Parse the data to get the symbols and size of arr
            dataTask.resume()
        }
        else {
            print("API Key not found")
        }
        
    }
}
struct SearchAPIRes: Decodable {
    var quotes: [Quote]
}

struct Quote: Decodable, Identifiable {
    var id: String { symbol }
    var symbol: String
}

struct SearchResult: View{
    public var ticker: String
    var body: some View{
        HStack {
            HStack{
                Text(ticker)
                    .padding(15)
                    .font(.title)
                    .frame(width:UIScreen.main.bounds.width*2/3)
            }
            .background()
            .opacity(0.8)
            .cornerRadius(20.0)
            .scenePadding(.top)
            NavigationLink(destination: PredictionPage(ticker: ticker)) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.black)
                    .padding(15)
                    .font(.title)
            }
            .background()
            .cornerRadius(20.0)
            .opacity(0.8)
            .scenePadding(.top)
        }
    }
}

#Preview {
    ContentView()
}
