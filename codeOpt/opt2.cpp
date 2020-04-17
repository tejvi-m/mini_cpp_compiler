#include <boost/algorithm/string/classification.hpp> // Include boost::for is_any_of
#include <boost/algorithm/string/split.hpp> // Include for boost::split
#include <iostream>
#include <vector>
#include <fstream>
#include <unordered_map>
#include <unordered_set>
#include <ctype.h>
#include <boost/lexical_cast.hpp>
// #include "tinyexpr.h"




using namespace std;

unordered_map<string, float> IDs;
vector<string> res;

float eval(vector<string>& words){

  if(words[3] == "+"){
    return boost::lexical_cast<float>(words[2]) + boost::lexical_cast<float>(words[4]);
  }
  if(words[3] == "-"){
return boost::lexical_cast<float>(words[2]) - boost::lexical_cast<float>(words[4]);
  }
  if(words[3] == "*"){
    return boost::lexical_cast<float>(words[2]) * boost::lexical_cast<float>(words[4]);
  }
  if(words[3] == "/"){
    return boost::lexical_cast<float>(words[2]) / boost::lexical_cast<float>(words[4]);
  }
  else if(words[3] == "%"){
      return boost::lexical_cast<int>(words[2]) % boost::lexical_cast<int>(words[4]);
  }
}


vector<string> removeDeadCode(vector<string> program){
  int initialSize = program.size();

  vector<string> new_prg;
  unordered_set<string> RHStemps;
  vector<string> words;

  // for(auto line: program){
  //       if(line != ""){
  //         boost::split(words, line, boost::is_any_of(" "), boost::token_compress_on);
  //         if(words[0][0] == 't'){
  //           LHStemps.insert(words[0]);
  //         }
  //
  //       }
  // }

  for(auto line: program){
        if(line != ""){
          boost::split(words, line, boost::is_any_of(" "), boost::token_compress_on);
          if(words.size() > 1 && words[1] == "="){
              for(int i = 2; i < words.size(); i++){
              if(words[i][0] == 't'){
                RHStemps.insert(words[i]);
              }
            }

          }
    }
  }

    for(auto line: program){
          if(line != ""){
            boost::split(words, line, boost::is_any_of(" "), boost::token_compress_on);
            if(words[0][0] != 't' || (words[0][0] == 't' && RHStemps.find(words[0]) != RHStemps.end())){
                new_prg.push_back(line);
            }

          }
    }

    if(new_prg.size() == initialSize){
      return new_prg;
    }
    else return removeDeadCode(new_prg);

  
}

bool is_number(const std::string& s)
{
    std::string::const_iterator it = s.begin();
    while (it != s.end() && std::isdigit(*it)) ++it;
    return !s.empty() && it == s.end();
}

void variable_propogate(vector<string>& program, unordered_set<string>& ignore){
  vector<string> words;

  bool flag = 0;
  string expr = "";
  for(auto line: program){
      if(line != "" ){

        if(line.find(":") != std::string::npos){
          res.push_back(line);
        }
        else {
          flag = 0;
          expr = "";
          boost::split(words, line, boost::is_any_of(" "), boost::token_compress_on);
          words.erase(remove(words.begin(), words.end(), ""), words.end());
          if(ignore.find(words[0]) == ignore.end()){
            cout << words[1] << endl;
            if(words.size() > 1 && words[1] == "="){

              for(int i = 2; i < words.size(); i++){
                if(!is_number(words[i])){
                  if(IDs.find(words[i]) != IDs.end()){
                    words[i] =  to_string(IDs[words[i]]);
                    flag = 1;
                  }

                }
                else{
                  if(words.size() == 3){
                     IDs[words[0]] = boost::lexical_cast<float>(words[2]);
                  }
                }
                expr += words[i];
              }
            }
            if(words.size() == 5){
              IDs[words[0]] = eval(words);
              res.push_back(words[0] + " = " + to_string(IDs[words[0]]));
            }
            else res.push_back(line);

        }
        }

      }
  }
}

// void find_for_loops(vector<string>& p)
int main(){
  ifstream in("./codeOpt/op.txt");
  unordered_set<string> ignore({"if", "goto"});
  if(!in.is_open()) throw std::runtime_error("Could not open file");
  std::string contents((std::istreambuf_iterator<char>(in)),
                          std::istreambuf_iterator<char>());

  vector<string> program;
  boost::split(program, contents, boost::is_any_of("\n"), boost::token_compress_on);
  cout << program.size();


  // variable_propogate(program, ignore);

  auto res1 = removeDeadCode(program);

  for(auto line: res1){
    cout << line << endl;
  }
}
