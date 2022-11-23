#!/bin/bash
#
tabchar="\t"

rm retweeted_hashtags_1.txt
rm retweets_hashtags_freqs.tsv
awk -F "\t" '{print $4, "\n"}' retweeted_cols.tsv > retweeted_hashtags_1.txt
sed 's/,/\n/g' retweeted_hashtags_1.txt |  iconv -f utf-8 -t ascii//TRANSLIT | sed 's/"//g' | sed 's/\b[a-z]\b//g' | sed 's/\b[A-Z]\b//g' | sed 's/ //g' | sed '/^$/d' | sort | uniq -c | sort -nr > retweeted_hashtags_2.txt
awk '{$0=NR>1?$0"\t":$0"\t"}1' retweeted_hashtags_2.txt > retweeted_hashtags_3.txt
grep -v "?" retweeted_hashtags_3.txt > retweeted_hashtags.txt

totalHashtags=`wc -l retweeted_hashtags.txt | awk -F " " '{print $1}'`
echo $totalHashtags

# add file header
printf "hashtag_H\tcluster_C_leader(userID)\trelative_frequency_H_C\tfrequency_H_in_C\tfrequency_H_overall\tcount_H_in_C\tcount_tweets_in_C\tcount_H_entire_dataset\tcount_tweets_entire_dataset\n" > retweets_hashtags_freqs.tsv
 
allfiles=`ls -f infl_retweets/*.hashtags`
for infile in $allfiles;
do
	sort $infile | uniq -c | sort -nr > temp1.txt
	#
	file="temp1.txt"
	col2=$(echo $infile | awk -F '[/.]' {'print $2'})
	echo $col2
	#
	while IFS= read -r line;
	do
		col1=$(	echo "$line" | awk -F ' ' {'print $2'})
		num=$(echo "$line" | awk -F ' ' {'print $1'})
		den=`wc -l temp1.txt | awk -F ' ' '{print $1}'`
		col4=`echo "scale=5; $num/$den" | bc`
		col6=$num
		col7=$den
		col8=$(grep -P " ${col1}${tabchar}" retweeted_hashtags.txt | awk -F " " {'print $1'})
		col9=$totalHashtags
		col5=`echo "scale=5; $col8/$col9" | bc`
		col3=`echo "scale=5; $col4/$col5" | bc`
		printf "$col1\t$col2\t$col3\t$col4\t$col5\t$col6\t$col7\t$col8\t$col9\\n" >> retweets_hashtags_freqs.tsv

	done < $file
	#
done
