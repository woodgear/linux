#ifndef _NET_WG_DEBUG_H
#define _NET_WG_DEBUG_H


#include <linux/netfilter.h>	
#include <linux/ip.h>
#include <net/tcp.h>
#include <net/udp.h>
#include <linux/netfilter/nf_conntrack_tuple_common.h>
#include <net/netfilter/nf_conntrack_tuple.h>

static inline char* tcp_flags_to_string(struct tcphdr *tcph) {
    static char flags[9];
    flags[0] = (tcph->syn) ? 'S' : '.';
    flags[1] = (tcph->ack) ? 'A' : '.';
    flags[2] = (tcph->fin) ? 'F' : '.';
    flags[3] = (tcph->rst) ? 'R' : '.';
    flags[4] = (tcph->psh) ? 'P' : '.';
    flags[5] = (tcph->urg) ? 'U' : '.';
    flags[6] = (tcph->ece) ? 'E' : '.';
    flags[7] = (tcph->cwr) ? 'C' : '.';
    flags[8] = '\0';
    return flags;
}

static inline char*  hooknum_to_string(unsigned int hooknum) {
    static char buf[128];
    switch(hooknum) {
        case NF_INET_PRE_ROUTING:
            snprintf(buf, sizeof(buf), "NF_INET_PRE_ROUTING");
            break;
        case NF_INET_LOCAL_IN:
            snprintf(buf, sizeof(buf), "NF_INET_LOCAL_IN");
            break;
        case NF_INET_FORWARD:
            snprintf(buf, sizeof(buf), "NF_INET_FORWARD");
            break;
        case NF_INET_LOCAL_OUT:
            snprintf(buf, sizeof(buf), "NF_INET_LOCAL_OUT");
            break;
        case NF_INET_POST_ROUTING:
            snprintf(buf, sizeof(buf), "NF_INET_POST_ROUTING");
            break;
        default:
            snprintf(buf, sizeof(buf), "Unknown hooknum: %u", hooknum);
    }
    return buf;
}

static inline char*  skb_to_string(struct sk_buff *skb) {
    static char buf[128];
    struct sk_buff *__skb = skb; 
    struct iphdr *__ip_header; 
    struct tcphdr *__tcp_header; 
    struct udphdr *__udp_header; 

    if (__skb->protocol == htons(ETH_P_IP)) { 
        __ip_header = ip_hdr(__skb); 
        if (__ip_header->protocol == IPPROTO_TCP) { 
			__tcp_header = tcp_hdr(__skb); 
            sprintf(buf,"tcp skb saddr: %pI4 daddr: %pI4 sport: %u dport: %u seq %u %s", &__ip_header->saddr,&__ip_header->daddr,ntohs(__tcp_header->source),ntohs(__tcp_header->dest),__tcp_header->seq,tcp_flags_to_string(__tcp_header)); \
        } else if (__ip_header->protocol == IPPROTO_UDP) { 
            __udp_header = udp_hdr(__skb); 
            sprintf(buf,"udp skb saddr: %pI4 daddr: %pI4 sport: %u dport: %u", &__ip_header->saddr,&__ip_header->daddr,ntohs(__udp_header->source),ntohs(__udp_header->dest)); 
        } 
    } 
    return buf;
}

static inline char*  tuple_to_string(struct nf_conntrack_tuple  *tuple) {
    static char buf[128];
    snprintf(buf, sizeof(buf), "src=%pI4:%hu, dst=%pI4:%hu, proto=%hhu",
             &(tuple->src.u3.ip), ntohs(tuple->src.u.all),
             &tuple->dst.u3.ip, ntohs(tuple->dst.u.all),
             tuple->dst.protonum);
    return buf;
}

#endif	